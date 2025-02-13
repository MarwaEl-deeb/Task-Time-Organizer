#!/bin/bash

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
cyan='\033[0;36m'
defultColor='\033[0m'  
#--------------------------------------------------#

workTime=1500
breakTime=300 
#--------------------------------------------------#

tasksFile="tasks.txt"
sessionCount=0
TstudyHours=0
TbreakHours=0
PAUSE_FLAG=0
currentTime=0
Label=""

# Daily Tracking Variables
dailySessionCount=0
dailyStudyHours=0
dailyBreakHours=0
today=$(date +"%Y-%m-%d")
dailySessionStatsFile="session_stats.txt"

#--------------------------------------------------#

[ ! -f "$tasksFile" ] && touch "$tasksFile"
#--------------------------------------------------#

show_menu() {
  echo -e "\n${red}*-*-*-*-*Your Tasks & Time Organizier*-*-*-*-*${defultColor}"
  echo -e "${cyan}1. Add New Task${defultColor}"
  echo -e "${cyan}2. Delete Task${defultColor}"
  echo -e "${cyan}3. Mark Task as Completed${defultColor}"
  echo -e "${cyan}4. View Tasks${defultColor}"
  echo -e "${cyan}5. Start Pomodoro Session${defultColor}"
  echo -e "${cyan}6. Start Break${defultColor}"
  echo -e "${cyan}7. View Sessions Status${defultColor}"
  echo -e "${cyan}8. Exit\n${defultColor}"
  echo -ne "${yellow}Choose an option: ${defultColor}"
}

add_task() {
  echo -ne "${yellow}Enter new task to add: ${defultColor}"
  read task
  echo "[ ] $task" >> "$tasksFile"
  echo -e "${green}Task added successfully.${defultColor}"
}


delete_task() {
  echo -e "${yellow}Select task to delete:${defultColor}"
  view_tasks
  echo -ne "${yellow}Enter task number: ${defultColor}"
  read task_number
  sed -i "${task_number}d" "$tasksFile"
  echo -e "${red}Task deleted successfully.${defultColor}"
}

mark_completed() {
  echo -e "${yellow}Select task to mark as completed:${defultColor}"
  view_tasks
  echo -ne "${yellow}Enter task number: ${defultColor}"
  read task_number
  sed -i "${task_number}s/\[ \]/[✔]/" "$tasksFile"
  echo -e "${green}Task marked as completed successfully.${defultColor}"
}

view_tasks() {
  echo -e "\n${cyan}#-#-# Tasks List #-#-#${defultColor}"
  nl -w 2 -s '. ' "$tasksFile"
}


view_s_status() {
  echo -e "\n${cyan}#-#-# Pomodoro Session Stats #-#-#${defultColor}"
  echo "Number of Completed Sessions Today: $dailySessionCount"
  echo "Total Study Hours Today: $((dailyStudyHours / 3600))h $(((dailyStudyHours % 3600) / 60))m"
  echo "Total Break Time Today: $((dailyBreakHours / 60))m"
}

countdown() {
  local duration=$1
  currentTime=$duration

  echo -e "Press ${green}p${defultColor} to (Pause or Resume), ${red}q${defultColor} to (Quit), or ${cyan}s${defultColor} to (Switch Session / Break)."
  
  while [ $currentTime -gt 0 ]; do
    if [ $PAUSE_FLAG -eq 0 ]; then
      printf "\r%02d:%02d remaining for %s... | ${cyan}Sessions Completed Today: %d | Total Study Hours Today: %02d:%02d${defultColor}" \
             $((currentTime / 60)) $((currentTime % 60)) "$Label" "$dailySessionCount" $((dailyStudyHours / 3600)) $(((dailyStudyHours % 3600) / 60))
      sleep 1
      ((currentTime--))
    fi

    read -t 0.1 -n 1 key
    case $key in
      p) 
        if [ $PAUSE_FLAG -eq 0 ]; then
          echo -e "\n${red}Paused. Press 'p' to resume.${defultColor}"
          PAUSE_FLAG=1
        else
          echo -e "\n${green}Resuming...${defultColor}"
          PAUSE_FLAG=0
        fi
        ;;
      q) 
        exit 0
        ;;
      s) 
        echo -e "\n${yellow}Switching session...${defultColor}"
        if [ "$Label" == "Work Session" ]; then
          start_break
        else
          start_session
        fi
        return
        ;;
    esac
  done
  echo ""
}

start_session() {
  Label="Work Session"
  echo -e "${cyan}Starting Pomodoro Session...${defultColor}"
  countdown $workTime
  ((sessionCount++))
  ((dailySessionCount++))
  dailyStudyHours=$((dailyStudyHours + workTime))
  echo "$today" > "$dailySessionStatsFile"  
  echo "$dailySessionCount" >> "$dailySessionStatsFile"
  echo "$dailyStudyHours" >> "$dailySessionStatsFile"
  echo "$dailyBreakHours" >> "$dailySessionStatsFile"
  TstudyHours=$((TstudyHours + workTime))
  echo -e "${green}Session completed!${defultColor}"
  start_break
}

start_break() {
  Label="Break"
  echo -e "${cyan}Starting Break...${defultColor}"
  countdown $breakTime
  dailyBreakHours=$((dailyBreakHours + breakTime))
  echo "$today" > "$dailySessionStatsFile"  
  echo "$dailySessionCount" >> "$dailySessionStatsFile"
  echo "$dailyStudyHours" >> "$dailySessionStatsFile"
  echo "$dailyBreakHours" >> "$dailySessionStatsFile"
  echo -e "${red}Break over!${defultColor}"
  start_session
}

while true; do
  show_menu
  read choice
  case $choice in
    1) add_task ;;
    2) delete_task ;;
    3) mark_completed ;;
    4) view_tasks ;;
    5) start_session ;;
    6) start_break ;;
    7) view_s_status ;;
    8) exit 0 ;;
    *) echo -e "${red}Invalid option. Try again.${defultColor}" ;;
  esac
done