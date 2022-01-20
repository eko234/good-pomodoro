(declare-project
 :name "good-pomodoro"
 :description "pretty tomato"
 :dependencies ["https://github.com/janet-lang/argparse.git"
                "https://github.com/janet-lang/spork.git"])

(declare-executable
 :name "good-pomodoro"
 :entry "main.janet"
 :lflags ["-static"])
