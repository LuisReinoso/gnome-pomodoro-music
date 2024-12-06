#!/bin/bash

# Variables
DEBUGFILE="$HOME/focus-music/pomodoro-debug-log.txt"
WORK_MUSIC="$HOME/focus-music/focus.mp3"
REST_MUSIC="$HOME/focus-music/relax.mpga"
PID_FILE="/tmp/pomodoro_music.pid"
TRIGGER="$1"
STATE="$2"
DEBUGMODE="$3"

isDebugMode=false

# Check if debug mode is enabled
if [ "$DEBUGMODE" == "debug" ]; then
  isDebugMode=true
fi

log_message() {
  local message="$1"
  
  # Always print to console
  echo "$message"

  # Log to debug file if in debug mode
  if [ "$isDebugMode" = true ]; then
    echo "$message" >> "$DEBUGFILE"
  fi
}

log_message "Running script at $(date)"
log_message "Trigger: $TRIGGER"
log_message "State: $STATE"

play_music() {
  log_message "Playing: $1"
  mpg123 "$1" &
  echo $! > "$PID_FILE"  # Save the PID of the music process
}

stop_music() {
  if [ -f "$PID_FILE" ]; then
    kill "$(cat "$PID_FILE")" 2>/dev/null
    rm "$PID_FILE"
    log_message "Music stopped"
  else
    log_message "No music process found to stop"
  fi
}

pause_music() {
  if [ -f "$PID_FILE" ]; then
    kill -STOP "$(cat "$PID_FILE")" 2>/dev/null
    log_message "Music paused"
  else
    log_message "No music process found to pause"
  fi
}

resume_music() {
  if [ -f "$PID_FILE" ]; then
    kill -CONT "$(cat "$PID_FILE")" 2>/dev/null
    log_message "Music resumed"
  else
    log_message "No music process found to resume"
  fi
}

start_pomodoro() {
  stop_music  # Stop any currently playing music
  play_music "$WORK_MUSIC"
}

start_break() {
  stop_music  # Stop any currently playing music
  play_music "$REST_MUSIC"
}

case "$TRIGGER" in
  start)
    if [ "$STATE" == "short-break" ] || [ "$STATE" == "long-break" ]; then
      start_break
    else
      start_pomodoro
    fi
    ;;
  break)
    start_break
    ;;
  disable)
    stop_music
    ;;
  skip)
    stop_music
    log_message "Skip command received. No music will be played."
    ;;
  pause)
    pause_music
    ;;
  resume)
    resume_music
    ;;
  *)
    log_message "Usage: $0 {start|break|disable|pause|resume|skip} {pomodoro|short-break|long-break} {debug}"
    exit 1
    ;;
esac