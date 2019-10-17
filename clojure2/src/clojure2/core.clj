(ns clojure2.core)

(def interval-count 100)

(defn f-i [f x i]
  (f (* (/ x interval-count) i)))

(def f-i-memoized (memoize f-i))

(defn integrate [f x]
  (* (/ x interval-count)
     (+ (reduce +
                (map (fn [i] (f-i-memoized f x i))
                     (range 1 interval-count)))
        (/ (+ (f-i-memoized f x interval-count) (f-i-memoized f x 0)) 2))))

(defn square [x] (* x x))

(defn -main [& args]
  (println (time (integrate square 5))
           (time (integrate square 6))
           (time (integrate square 7))
           (time (integrate square 8))
           (time (integrate square 9))
           (time (integrate square 10))))