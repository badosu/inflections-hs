module Text.Inflections.Tests where

import Test.HUnit hiding (Test)

import Test.Framework.Providers.QuickCheck2 (testProperty)

import Test.QuickCheck
import Test.QuickCheck.Arbitrary

import Test.Framework (Test, testGroup)

import Data.List (all, group)
import Data.Char (toLower)
import Data.Map (fromList)

import Text.Inflections

{-# ANN module "HLint: ignore Use camelCase" #-}

tests :: [Test]
tests = [testGroup "dasherize"
         [ testProperty "Substitutes spaces for hyphens" prop_dasherize1
         ],

         testGroup "parameterize"
         [ testProperty "Contains only valid chars"
                        prop_parameterize1
         , testProperty "Does not begin with a separator character"
                         prop_parameterize2
         , testProperty "Does not end in a separator character"
                         prop_parameterize3
         , testProperty "All alphanumerics in input exist in output"
                        prop_parameterize4
         , testProperty "Doesn't have subsequences of more than one hyphen"
                        prop_parameterize5
         ]
        ]


prop_dasherize1 :: String -> Property
prop_dasherize1 s =
    '-' `notElem` s ==> numMatching '-' (dasherize s) == numMatching ' ' s

prop_parameterize1 :: String -> Bool
prop_parameterize1 sf = all (`elem` (alphaNumerics ++ "-_")) $
                        parameterize defaultTransliterations sf

prop_parameterize2 :: String -> Property
prop_parameterize2 s =
    (not . null) parameterized ==> head parameterized /= '-'
    where parameterized = parameterize defaultTransliterations s

prop_parameterize3 :: String -> Property
prop_parameterize3 s =
    (not . null) parameterized ==> last parameterized /= '-'
    where parameterized = parameterize defaultTransliterations s

prop_parameterize4 :: String -> Bool
prop_parameterize4 s = all (\c -> c `notElem` alphaNumerics ||
                              c `elem` (alphaNumerics ++ "-") &&
                              c `elem` parameterized) $ map toLower s
    where parameterized = parameterize defaultTransliterations s

prop_parameterize5 :: String -> Bool
prop_parameterize5 s = longestSequenceOf '-' parameterized <= 1
    where parameterized = parameterize defaultTransliterations s


-- Helper functions and shared tests

longestSequenceOf :: Char -> String -> Int
longestSequenceOf c [] = 0
longestSequenceOf c s =
    if null subseqLengths then 0 else maximum subseqLengths

  where subseqLengths = (map length . filter (\str -> head str == c) . group) s

numMatching char str = length $ filter (== char) str

alphaNumerics :: String
alphaNumerics = ['a'..'z'] ++ ['0'..'9']