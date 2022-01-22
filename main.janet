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
                    :default 1500
                    :help "duh"}
   "short-break-duration" {:kind :option
                           :required false
                           :short "b"
                           :default 300
                           :help "really?"}
   "long-break-duration" {:kind :option
                          :required false
                          :short "B"
                          :default 1800
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
 skip: skip to next segment``}
   :default {:kind :accumulate}])

(defn make-model [options time]
  @{:origin time
    :options options
    :event-buffer @[]
    :king-crimson 0})

(defn make-event [event time]
  @{:type event :time time})

(defn pomodoro-save-model [task model]
  (spit (string (dyn :tomato-folder) "/" task) (marshal model)))

(defn pomodoro-read-model [task]
  (unmarshal (slurp (string (dyn :tomato-folder) "/" task))))

(defn task-exist? [task]
  (find |(= task $) (os/dir (dyn :tomato-folder))))

(defn pomodoro-start [task options time]
  (assert (not (task-exist? task)) "task already exists")
  (pomodoro-save-model task (make-model options time)))

(defn pomodoro-end [task time]
  "sets a final timestamp to podoro and moves it away")


(defn consec
  "takes a binary function and an array and return
  consecutive elements as defined by the provided function"
  [f a]
  (reduce |(if (f $0 $1) $0 [;$0 $1]) [] a))

(defn pomodoro-is-paused? [pauses continues]
  (label result
    (do
      (when (or (empty? pauses)
                (and (empty? pauses)
                     (empty? continues)))
        (return result false))
      (> (get (last pauses) :time -1)
         (get (last continues) :time -2)))))

(defn substract-intervals [])

(defn shift-segmants [segments]
  [;(drop 1 segments) (get segments 0)])

(defn pomodoro-segment [computed-time model]
  (let
    [{:origin origin
      :options {:long-break-duration long-break-duration
                :short-break-duration short-break-duration
                :work-duration work-duration}} model]
    (var car (- computed-time origin))
    # TODO check for arity of segments
    (var segments [["work" work-duration]
                   ["short-break" short-break-duration]
                   ["work" work-duration]
                   ["short-break" short-break-duration]
                   ["work" work-duration]
                   ["long-break" long-break-duration]])
    (def segments-length (length segments))
    (label result
      (forever
        (def next-car (- car (last (first segments))))
        (if (<= next-car 0)
          (return result [(first (first segments)) next-car])
          (do
            (set segments (shift-segmants segments))
            (set car next-car)))))))

(defn format-time [time]
  (let [{:minutes minutes
         :seconds seconds} (os/date time)]
    (if (= (length (string seconds)) 1)
      (string/format "%d:0%d" minutes seconds)
      (string/format "%d:%d" minutes seconds))))

(defn pomodoro-pretty [task model computed-time] 
  (let
    [events (model :event-buffer)
     consecutive-events-by-type (consec |(= (get (last $0) :type) ($1 :type)) events)
     events-by-type (group-by |($ :type) consecutive-events-by-type)
     pauses (get events-by-type :pause [])
     continues (get events-by-type :continue [])
     paused? (pomodoro-is-paused? pauses continues)
     origin (model :origin)
     format-string (if paused?
                     " %s %s ■ "
                     " %s %s ▲ ")
     [segment left] (pomodoro-segment computed-time model)]
    (string/format format-string segment (format-time (math/abs left)))))

(defn pomodoro-show [task time]
  (let
    [model (pomodoro-read-model task)
     king-crimson (model :king-crimson)
     computed-time (- time king-crimson)]
    (pomodoro-pretty task model computed-time)))

(defn pomodoro-save-event [task event time]
  (let
    [model (pomodoro-read-model task)
     event-buffer (model :event-buffer)
     king-crimson (model :king-crimson)
     computed-time (- time king-crimson)
     last-event (last event-buffer)
     new-event (make-event event computed-time)]
    (array/push event-buffer new-event)
    (if-let
      [exist last-event
       last-event-type (last-event :type)
       is-pause (= last-event-type :pause)
       is-continue (= event :continue)
       time-difference (- computed-time (last-event :time))]
      (put model :king-crimson (+ king-crimson time-difference)))
    (pomodoro-save-model task model)))


(comment if there is a pause before and this is a continue ,increase king crimson
         by substracting the time from the pause with current time ,king crimson
         will be used to substract from current time from now on)

(defn good-pomodoro
  [cmd task options time]
  (match cmd
    "show" (pomodoro-show task time)
    "start" (pomodoro-start task options time)
    "end" (pomodoro-end task time)
    "pause" (pomodoro-save-event task :pause time)
    "continue" (pomodoro-save-event task :continue time)
    "skip" (pomodoro-save-event task :skip time)))

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
      (print (good-pomodoro command task options (os/time))))))

# cambiar origen por la ultima pause


now =>
on pause
on continue





now
pause
continue



