(import argparse :prefix "")

(def argparse-params
  [``Good-Pomodoro is a cli program to define simple pomodoro
   work stuff things, internally a pomodoro is just a file with
   that represents a struct with a timestamp field to trak when
   the pomodoro started, an options field to parameterize times
   and a buffer to store pauses, skips,
   interruptions, etc``
   "work-duration"
   {:kind :option
    :required false
    :short "w"
    :default 1500
    :help "duh"}

   "short-break-duration"
   {:kind :option
    :required false
    :short "b"
    :default 300
    :help "really?"}

   "long-break-duration"
   {:kind :option
    :required false
    :short "B"
    :default 1800
    :help "sweet long breaks"}

   "init"
   {:kind :flag
    :required false
    :short "i"
    :help "create the default folder if not exists"}

   "command"
   {:kind :option
    :short "c"
    :required false
    :default "show"
    :help ``
 command to run, one of (show|start|end|pause|continue|skip)
 show: prints to stdout the status 
 start: creates a new pomodoro 
 end: stops a running pomodoro and stores its data into the vault
 pause: pauses a pomodoro
 continue: resumes a paused pomodoro
 skip: skip to next segment``}

   :default
   {:kind :accumulate}])

(defn make-model [options]
  {:options options
   :buffer @[]})

(defn format-pomodoro [model time]
  (let
    [{:long-break-duration long-break-duration
      :short-break-duration short-break-duration
      :work-duration work-duration} (get model :options)
     buffer (get model :buffer)
     intervals [work-duration
                short-break-duration
                work-duration
                short-break-duration
                long-break-duration]]
    (var current-segment 0)
    (var time-elapsed 0)
    (loop [event :in buffer]
      )
    maybe use a reduce function?))

(defn show-pomodoro [time]
  (let
    [model (load-model)]
    (format-pomodoro model time)))

(defn start-pomodoro [options time]
  (let
    [model (make-model options)]
    (array/push (get model :buffer) {:type :play :time time})
    (save-model model)))

(defn stop-pomodoro [time]
  (let
    [model (load-model)]
    (array/push (get model :buffer) {:type :stop :time time})
    (save-model model)))

(defn skip-pomodoro [time]
  (let
    [model (load-model)]
    (array/push (get model :buffer) {:type :skip :time time})
    (save-model model)))

(defn play-pomodoro [time]
  (let
    [model (load-model)]
    (array/push (get model :buffer) {:type :play :time time})
    (save-model model)))

(defn end-pomodoro [time]
  (let
    [model (load-model)]
    (array/push (get model :buffer) {:type :stop :time time})
    (save-model model)
    (archive-model)))

(defn good-pomodoro [command options time]
  (case command
    "show" (show-pomodoro time)
    "start" (start-pomodoro options time)
    "play" (play-pomodoro options time)
    "stop" (stop-pomodoro time)
    "skip" (skip-pomodoro time)
    "end" (end-pomodoro time)))

(defn main [& _]
  (setdyn :tomato-folder (string (get (os/environ) "HOME") "/.good-pomodoro"))
  (let [{"long-break-duration" long-break-duration
         "short-break-duration" short-break-duration
         "work-duration" work-duration
         "init" init #TODO find a sensible way to initialize this shit
         "command" command} (argparse ;argparse-params)
        options {:long-break-duration long-break-duration
                 :short-break-duration short-break-duration
                 :work-duration work-duration}]
    (if init
      (do
        (os/mkdir (dyn :tomato-folder))
        (print "napolitan folder cooked"))
      (print (good-pomodoro command options (os/time))))))
