import socketio
import asyncio
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles

# Setup
fastapi_app = FastAPI()
fastapi_app.mount("/", StaticFiles(directory="static", html=True), name="static")
sio = socketio.AsyncServer(async_mode='asgi', cors_allowed_origins='*')
app = socketio.ASGIApp(sio, other_asgi_app=fastapi_app)

# --- GAME STATE ---
game_state = {
    "status": "waiting",
    "current_question_index": -1,
    "players": {},       # {sid: {name, score}}
    "answers": {},       # {sid: answer_index}
    "answer_order": []   # [sid1, sid2...] for speed bonus
}

QUESTIONS = [
    {"q": "What is the capital of France?", "options": ["London", "Berlin", "Paris", "Madrid"], "correct": 2},
    {"q": "Which planet is the Red Planet?", "options": ["Earth", "Mars", "Jupiter", "Venus"], "correct": 1},
    {"q": "What is 2 + 2?", "options": ["3", "4", "5", "Fish"], "correct": 1},
    {"q": "Who wrote Hamlet?", "options": ["Shakespeare", "Hemingway", "Orwell", "Austen"], "correct": 0}
]

# --- LOGIC ---

async def start_question_timer(question_index):
    # Wait 15 seconds
    for i in range(15, 0, -1):
        # Stop if the game moved on (Host clicked next early)
        if game_state["current_question_index"] != question_index:
            return

        await sio.emit('timer_update', i) 
        await asyncio.sleep(1)
        
        # Check if everyone answered
        active_players = len(game_state["players"])
        if active_players > 0 and len(game_state["answers"]) == active_players:
            break
    
    # Timer finished, check if we are still on the same question
    if game_state["current_question_index"] == question_index:
        await calculate_scores()

async def calculate_scores():
    if game_state["status"] == "result":
        return # Already calculated

    game_state["status"] = "result"
    idx = game_state["current_question_index"]
    correct_opt = QUESTIONS[idx]["correct"]
    
    # SPEED SCORING: 1st=100, 2nd=90, ... Min=10
    base_score = 100
    
    for rank, sid in enumerate(game_state["answer_order"]):
        if sid in game_state["players"]:
            # Check if answer is correct
            if game_state["answers"].get(sid) == correct_opt:
                points = max(10, base_score - (rank * 10))
                game_state["players"][sid]["score"] += points

    # 1. Send Results to Players (VR)
    await sio.emit('show_results', {
        "correct_option": correct_opt,
        "players": game_state["players"]
    })
    
    # 2. FORCE UPDATE HOST SCOREBOARD (Fixes Issue #2)
    print("Sending updated scoreboard to host...")
    await sio.emit('player_list_update', game_state["players"])

# --- SOCKET EVENTS ---

@sio.event
async def connect(sid, environ):
    print(f"Connected: {sid}")

@sio.event
async def join_game(sid, data):
    game_state["players"][sid] = {
        "name": data.get("name", "Guest"),
        "score": 0
    }
    # Update Host immediately
    print(f"Player Joined: {data.get('name', 'Guest')}")
    await sio.emit('player_list_update', game_state["players"])

@sio.event
async def submit_answer(sid, answer_index):
    if game_state["status"] == "question" and sid not in game_state["answers"]:
        game_state["answers"][sid] = answer_index
        game_state["answer_order"].append(sid)
        print(f"Player {sid} answered.")

# --- HOST CONTROLS ---

@sio.event
async def host_next_question(sid):
    # Move to next
    game_state["current_question_index"] += 1
    idx = game_state["current_question_index"]
    
    if idx < len(QUESTIONS):
        # RESET FOR NEW QUESTION (Fixes Issue #3 - Buttons working)
        game_state["status"] = "question"
        game_state["answers"] = {} 
        game_state["answer_order"] = []
        
        # Broadcast Question
        question_data = {
            "q": QUESTIONS[idx]["q"],
            "options": QUESTIONS[idx]["options"]
        }
        await sio.emit('show_question', question_data)
        
        # Start Timer Task
        asyncio.create_task(start_question_timer(idx))
    else:
        await sio.emit('game_over', game_state["players"])

@sio.event
async def host_reset_game(sid):
    # Full Reset without killing server
    game_state["current_question_index"] = -1
    game_state["status"] = "waiting"
    game_state["answers"] = {}
    game_state["answer_order"] = []
    
    # Reset Scores but keep players connected
    for pid in game_state["players"]:
        game_state["players"][pid]["score"] = 0
        
    await sio.emit('player_list_update', game_state["players"])
    print("GAME RESET - READY FOR NEW ROUND")

@sio.event
async def disconnect(sid):
    if sid in game_state["players"]:
        del game_state["players"][sid]
        await sio.emit('player_list_update', game_state["players"])

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8080, ssl_keyfile="key.pem", ssl_certfile="cert.pem")