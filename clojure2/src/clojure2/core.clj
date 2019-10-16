(ns clojure2.core)

(def interval-count 100)

(defn f-i [f x i]
  (f (* (/ x interval-count) i)))

(defn integrate [f x]
  (* (/ x interval-count)
     (+ (reduce +
                (map (fn [i] (f-i f x i))
                     (range 1 interval-count)))
        (/ (+ (f-i f x interval-count) (f-i f x 0)) 2))))

(defn -main [& args]
  (println (integrate (fn [x] (* x x)) 5)))