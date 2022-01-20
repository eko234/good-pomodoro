(import argparse :prefix "")

(def argparse-params
  [``Good-Pomodoro is a cli program to define simple pomodoro
   work stuff things, internally a pomodoro is just a file with
   that represents a struct with a timestamp field to trak when
   the pomodoro started, an options field to parameterize times
   and intervals and an event buffer to store, pauses, skips,
   interruptions, etc``
   #TODO reconfigure pomodoro flag
   #TODO add hooks
   #TODO make end be sensible too
   #TODO allow to parameterize sequences ie a pomodoro is a w|sb|w|sb|w|sb|w|lb sequence
   #TODO allow an option to define the path for storing files
   "work-duration" {:kind :option
                    :required false
                    :short "w"
                    :default 25
                    :help "duh"}
   "short-break-duration" {:kind :option
                           :required false
                           :short "b"
                           :default 5
                           :help "really?"}
   "long-break-duration" {:kind :option
                          :required false
                          :short "B"
                          :default 30
                          :help "sweet long breaks"}
   "task" {:kind :option
           :required false
           :short "t"
           :default "main"
           :help "name of the task, defaults to main"}
   "intervals" {:kind :option
                :required false
                :short "I"
                :help "sequential string representing work/break intervals in minutes"}
   "init" {:kind :flag
           :required false
           :short "i"
           :help "create the default folder if not exists"}
   "command" {:kind :option
              :short "c"
              :required false
              :default "show"
              :help ``
 command to run, one of (show|start|end|pause|continue|skip)
 show: prints to stdout the status of the selected task
 start: creates a new pomodoro if a given task is not a running pomodoro
 end: stops a running pomodoro and stores its data into the vault
 pause: pauses a pomodoro
 continue: resumes a paused pomodoro
 skip: skip to next segment
              ``}
   :default {:kind :accumulate}])

(defn make-model [options time]
  @{:origin time :options options :event-buffer @[]})

(defn make-event [event time]
  @{:type event :time time})

(defn pomodoro-save-model [task model]
  (spit (string (dyn :tomato-folder) "/" task) (marshal model)))

(defn pomodoro-read-model [task]
  (unmarshal (slurp (string (dyn :tomato-folder) "/" task))))

(defn task-exist? [task]
  (find |(= task $) (os/dir (dyn :tomato-folder))))

(defn pomodoro-start [task options]
  (assert (not (task-exist? task)) "task already exists")
  (pomodoro-save-model task (make-model options (os/time))))

(defn pomodoro-end [task]
  "sets a final timestamp to podoro and moves it away")

(defn pomodoro-is-paused? [model])

(defn pomodoro-segment [time model]
  ["12" "hello"])

(defn pomodoro-pretty [task model]
  (let
    [now (os/time)
     format-string (if (pomodoro-is-paused? model) "on %s | %s : %s paused" "on %s | %s : %s")
     [segment left] (pomodoro-segment now model)]
    (string/format format-string task segment left)))

(defn pomodoro-show [task]
  (let
    [model (pomodoro-read-model task)]
    (pomodoro-pretty task model)))

(defn pomodoro-save-event [task event]
  (let [model (pomodoro-read-model task)
        event-buffer (model :event-buffer)
        new-event (make-event event (os/time))]
    (array/push event-buffer new-event)
    (pomodoro-save-model task model)))

(defn good-pomodoro
  [cmd task options]
  (match cmd
    "show" (pomodoro-show task)
    "start" (pomodoro-start task options)
    "end" (pomodoro-end task)
    "pause" (pomodoro-save-event task :pause)
    "continue" (pomodoro-save-event task :continue)
    "skip" (pomodoro-save-event task :skip)))

(defn main [& _]
  (setdyn :tomato-folder (string (get (os/environ) "HOME") "/.good-pomodoro"))
  (let [{"long-break-duration" long-break-duration
         "short-break-duration" short-break-duration
         "work-duration" work-duration
         "intervals" intervals
         "init" init #TODO find a sensible way to initialize this shit
         "task" task
         "command" command} (argparse ;argparse-params)
        options {:long-break-duration long-break-duration
                 :short-break-duration short-break-duration
                 :work-duration work-duration
                 :intervals intervals}]
    (if init
      (do
        (os/mkdir (dyn :tomato-folder))
        (print "napolitan folder cooked"))
      (print (good-pomodoro command task options)))))
