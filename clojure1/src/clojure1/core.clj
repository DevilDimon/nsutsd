(ns clojure1.core)

(defn build-words [words character]
  (map (fn [word] (.concat word character))
    (remove (fn [word] (.endsWith word character))
      words)))

(defn words-with-characters [characters word-length]
  (reduce (fn [words _]
    (flatten
     (map (fn [character] (build-words words character))
       characters)))
       '("")
       (range 1 (inc word-length))))

(defn -main [& args]
  (println (words-with-characters '("a" "b" "c") 4)))