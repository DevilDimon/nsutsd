(ns clojure4.core-test
  (:require [clojure.test :refer :all]
            [clojure4.core :refer :all]
            [clojure4.core :as c]))

(deftest simple-test
  (testing "A ==> A"
    (is (= '(::c/var :a))
        (dnf-with-preprocessing (variable :a))))
  (testing "Single conjunction"
    (is (= '(::c/and (::c/var :a) (::c/var :b))
           (dnf-with-preprocessing (conjunction (variable :a) (variable :b))))))
  (testing "Single conjunction with var"
    (is (= '(::c/or (::c/and (::c/var :a) (::c/var :b)) (::c/var :c))
           (dnf-with-preprocessing (disjunction (conjunction (variable :a) (variable :b)) (variable :c))))))
  (testing "Two large conjunctions"
    (is (= '(::c/or (::c/and (::c/var :a) (::c/and (::c/not (::c/var :b)) (::c/not (::c/var :c))))
              (::c/and (::c/not (::c/var :d)) (::c/and (::c/var :e) (::c/var :f))))
           (dnf-with-preprocessing (disjunction
                  (conjunction (variable :a)
                               (conjunction (negation (variable :b)) (negation (variable :c))))
                  (conjunction (negation (variable :d))
                               (conjunction (variable :e) (variable :f))))))))
  (testing "Many conjunctions"
    (is (= '(::c/or (::c/and (::c/var :a) (::c/and (::c/var :b) (::c/not (::c/var :c))))
              (::c/or (::c/and (::c/not (::c/var :d)) (::c/and (::c/var :e) (::c/var :f)))
                (::c/or (::c/and (::c/var :c) (::c/var :d)) (::c/var :b))))
           (dnf-with-preprocessing (disjunction
                  (conjunction (variable :a) (conjunction (variable :b) (negation (variable :c))))
                  (disjunction
                    (conjunction (negation (variable :d)) (conjunction (variable :e) (variable :f)))
                    (disjunction (conjunction (variable :c) (variable :d)) (variable :b)))))))))

(deftest implication-test
  (testing "Simple implication"
    (is (= '(::c/or (::c/not (::c/var :a)) (::c/var :b))
           (dnf-with-preprocessing (implication (variable :a) (variable :b))))))
  (testing "Inner implication"
    (is (= '(::c/or (::c/not (::c/var :a)) (::c/or (::c/not (::c/var :b)) (::c/var :c)))
           (dnf-with-preprocessing (implication (variable :a) (implication (variable :b) (variable :c))))))))

(deftest complex-test
  (testing "Double implication with disjunction"
    (is (= '(::c/or
              (::c/and (::c/var :x)
                (::c/and (::c/not (::c/var :y)) (::c/not (::c/var :y))))
              (::c/and (::c/var :x)
                (::c/and (::c/not (::c/var :y)) (::c/var :z))))
           (dnf-with-preprocessing (negation (disjunction (implication (variable :x) (variable :y))
                                                          (negation (implication (variable :y) (variable :z))))))))))