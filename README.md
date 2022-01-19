# Good-Pomodoro

  So basically I got tired of trying all the pomodoro clis out
  there that seem to take a lot of assumptions of how the user
  wants to receive notifications and that also seem to provide
  a crufty interface to actually use the pomodoro technique,
  so here it is, another one, I should be workig right now...

### ADVICE!!
  This application is in a very early stage, it might break
  but shouldnt do anything terrible unless you tell it to


### USE
    `good-pomodoro -i`                           => creates the folder in the home dir
    `good-pomodoro`                              => when no args are passed good-pomodoro defaults to show main
    `good-pomodoro -c start`                     => creates a new pomodoro as default main
    `good-pomodoro -c start -t my-cool-project`  => creates a new pomodoro with task provided name 
    `good-pomodoro -c show -t my-cool-project`   => shows the status for a given name 
    `good-pomodoro -c (pause|continue|skip)`     => emits an event to alter the state of the pomodoro, further calls to show will return a propper state representation
