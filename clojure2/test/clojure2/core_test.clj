(ns clojure2.core-test
  (:require [clojure.test :refer :all]
            [clojure2.core :refer :all]))

(defn f-x [x] x)

(deftest zero-test
  (testing "Any integral from 0 to 0 should be 0"
    (is (= (integrate f-x 0) 0))))

(deftest simple-test
  (testing "Integral of 1 from 0 to x should be x"
    (is (= (integrate (fn [_] 1) 5) 5))))

(defn almost= [actual expected]
  (and (< actual (+ expected 1/1000)) (> actual (- expected 1/1000))))

(deftest sin-test
  (testing "Integral of sin(x) from 0 to π should be 2"
    (let [result (integrate (fn [x] (Math/sin x)) Math/PI)]
      (is (almost= result 2)))))

(deftest hard-f-test
  (testing "Integral of sin^2(x) + 2sin^4(2x) from 0 to π should be 5π/4"
    (let [result (integrate (fn [x]
                              (+ (Math/pow (Math/sin x) 2)
                                 (* 2 (Math/pow (Math/sin (* 2 x)) 4))))
                            Math/PI)]
      (is (almost= result (/ (* 5 Math/PI) 4))))))
