{
  "RemindersListScreen": {
    "header": {
      "title": "Reminders",
      "backgroundImage": "brain_illustrations_background.png"
    },
    "dateSelector": {
      "currentSelection": "Mon 13",
      "dates": [
        {
          "dayName": "Sun",
          "dayNumber": 12,
          "isSelected": false
        },
        {
          "dayName": "Mon",
          "dayNumber": 13,
          "isSelected": true
        },
        {
          "dayName": "Tue",
          "dayNumber": 14,
          "isSelected": false
        },
        {
          "dayName": "Wed",
          "dayNumber": 15,
          "isSelected": false
        }
      ]
    },
    "todaySection": {
      "label": "Today",
      "addButton": {
        "icon": "plus_circle",
        "action": "addNewReminder"
      }
    },
    "remindersList": [
      {
        "id": "reminder_001",
        "icon": "syringe_pills.png",
        "title": "Ritalin",
        "details": "1 pill",
        "time": "09:00 am",
        "isCompleted": true,
        "swipeActions": []
      },
      {
        "id": "reminder_002",
        "icon": "sleeping_brain.png",
        "title": "Sleep",
        "details": null,
        "time": "11:00 pm",
        "isCompleted": false,
        "swipeActions": []
      },
      {
        "id": "reminder_003",
        "icon": "lungs.png",
        "title": "Breath",
        "details": null,
        "time": "05:30 pm",
        "isCompleted": false,
        "swipeActions": [
          {
            "label": "Remove",
            "action": "removeReminder",
            "backgroundColor": "#FF5C5C"
          }
        ]
      },
      {
        "id": "reminder_004",
        "icon": "walking_brain.png",
        "title": "Walk",
        "details": null,
        "time": "05:30 pm",
        "isCompleted": false,
        "swipeActions": []
      },
      {
        "id": "reminder_005",
        "icon": "meditating_brain.png",
        "title": "Mindfulness",
        "details": null,
        "time": "05:30 pm",
        "isCompleted": false,
        "swipeActions": []
      },
      {
        "id": "reminder_006",
        "icon": "breaking_chains.png",
        "title": "BreakFree",
        "details": null,
        "time": "05:30 pm",
        "isCompleted": false,
        "swipeActions": []
      }
    ],
    "bottomNavigationBar": {
      "activeTab": "Reminders", 
      "tabs": [
        {
          "id": "home",
          "icon": "home_icon.png",
          "action": "navigateToHome"
        },
        {
          "id": "reminders",
          "icon": "clock_icon.png",
          "action": "navigateToReminders"
        },
        {
          "id": "tasks", 
          "icon": "list_icon.png",
          "action": "navigateToTasks"
        },
        {
          "id": "resources", 
          "icon": "book_icon.png",
          "action": "navigateToResources"
        },
        {
          "id": "profile",
          "icon": "profile_icon.png",
          "action": "navigateToProfile"
        }
      ]
    }
  }
}