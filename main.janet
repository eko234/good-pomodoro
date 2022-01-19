(import argparse :prefix "")
(import spork/rpc)

(def argparse-params
  [``Good-Pomodoro is a cli program to define simple pomodoro
   work stuff things, internally a pomodoro is just a file with
   a timestamp for when it started and several others to mark events
   like breaks``
   "end-tomato" {:kind :flag
                 :required false
                 :short "k"
                 :help "ends the current pomodoro process"}
   "watch-tomato" {:kind :flag
                   :required false
                   :short "w"
                   :help "displays current pomodoro process"}
   "work-duration" {:kind :option
                    :required true
                    :short "a"
                    :help "run as <server|client>"}
   "on-wrok-start" {:kind :option
                    :required false
                    :short "s"
                    :help "jibber jagger"}
   "on-wrok-end" {:kind :option
                    :required false
                    :short "s"
                    :help "jibber jagger"}
   "short-break-duration" {:kind :option
                           :required true
                           :short "k"
                           :help "key for authorization"}
   "long-break-duration" {:kind :option
                          :required true
                          :short "k"
                          :help "key for authorization"}
   :default {:kind :accumulate}])

(defn main [& cmdlargs]
  (let [parsed-args (argparse ;argparse-params)]
    (match (parsed-args "as")
      "server" (do
                 (init-server {:port (parsed-args "port") :host (parsed-args "host") :key (parsed-args "key")})
                 (printf "Running server at %s:%s" (parsed-args "host") (parsed-args "port")))
      "client" (do
                 (if-let
                   [[cmd args] [(keyword (first (parsed-args :default))) (drop 1 (parsed-args :default))]
                    key (parsed-args "key")
                    res (do-client {:cmd cmd :args args :key key :host (parsed-args "host") :port (parsed-args "port")})]
                   (pp res)
                   (pp :ERR)))
      _ (pp :shrug))))
