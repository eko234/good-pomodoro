(import argparse :prefix "")
(import spork/rpc)

(def argparse-params
  [`` Hooker is a cli application mainly used to automate deployment
   and handling of applications, it is best used
   for specific projects, exposing an rpc to be used remotely or
   locally (i know, i know...), so if you want to handle different
   projects the recommended way is to spawn multiple servers
   ``
   "as" {:kind :option
         :required true
         :short "a"
         :help "run as <server|client>"}
   "key" {:kind :option
          :required true
          :short "k"
          :help "key for authorization"}
   "host" {:kind :option
           :required true
           :short "h"
           :help "host to connect/listen to/from"}
   "port" {:kind :option
           :required true
           :short "p"
           :help "port to connect/listen to/from"}
   :default {:kind :accumulate}])

(def default-scripts-dir "./hookers")

(defn protect [payload key]
  (assert (= (payload :key) key)))

(def procc-store @{})
(defn init-server [{:port port :host host :key skey}]
  (rpc/server
    {:runR (fn [self {:key ckey :args args}]
             (assert (= ckey skey))
             (if-let
               [[script args] [(first args) (string/join (drop 1 args) " ")]
                exists (find |(= $ script) (os/dir default-scripts-dir))
                procc (os/spawn [(string/format "./hookers/%s" script) args] :p {:out :pipe :err :pipe :in :pipe})
                pid (procc :pid)]
               (do
                 (put procc-store pid procc)
                 {:res :OK :pid pid})
               {:res :NOT_FOUND}))
     :killR (fn [self {:key ckey :args [pid]}]
              (def parsed-pid (scan-number pid))
              (if-let [p (get procc-store parsed-pid)]
                (do
                  (os/proc-kill p)
                  (put procc-store parsed-pid nil)
                  {:res :OK})
                (do
                  {:res :NOT_FOUND})))
     :pidsR (fn [self {:key ckey}]
             (assert (= ckey skey))
             (map |($ :pid) procc-store))
     :listR (fn [self {:key ckey}]
              (assert (= ckey skey))
              (os/dir default-scripts-dir))}
    host
    port))

(defn do-client
  [{:cmd cmd :args args :key key :host host :port port}]
  (if-let [_ key
           funcs (rpc/client host port)
           func (funcs cmd)]
    (do
      (cmd funcs {:key key :args args}))
    :FAIL))

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
