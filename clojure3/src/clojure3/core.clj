(ns clojure3.core)

(def interval 1/10)

(defn f-i [f i]
  (f (* interval i)))

(defn f-i-seq [f i]
  (lazy-seq (cons (f-i f i) (f-i-seq f (dec i)))))

(defn integrate [f x]
  (* interval
     (+ (reduce + (take (- (/ x interval) 1) (f-i-seq f (dec (/ x interval)))))
        (/ (+ (f-i f (/ x interval)) (f-i f 0)) 2))))

(defn square [x] (* x x))

(defn -main [& args]
  (println (time (integrate square 10))
           (time (integrate square 9))
           (time (integrate square 8))
           (time (integrate square 7))
           (time (integrate square 6))
           (time (integrate square 5))))