(ns clojure4.core-test
  (:require [clojure.test :refer :all]
            [clojure4.core :refer :all]
            [clojure4.core :as c]))

(deftest implication-test
  (testing "Simple implication"
    (is (= '(::c/or (::c/not (::c/var :a)) (::c/var :b))
           (dnf (implication (variable :a) (variable :b))))))
  (testing "Inner implication"
    (is (= '(::c/or (::c/not (::c/var :a)) (::c/or (::c/not (::c/var :b)) (::c/var :c)))
           (dnf (implication (variable :a) (implication (variable :b) (variable :c))))))))