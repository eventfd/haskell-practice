# Functors

```haskell
class Functor f where
    fmap :: (a -> b) -> f a -> f b
    (<$) :: a -> f b -> f a
    {-# MINIMAL fmap #-}
```

1. Functors **does not extend** over curried functions. Why? Because the resulting curried function is **within context**. `Functor` does not provide a way to wrap function in a context. This issue is resolved by `Applicative`s

Let `f1 :: a -> b -> c`. If we type match with `a -> b`, we get, `f1 :: a -> (b -> c)`. Thus 
```haskell
fmap :: (a -> b -> c) -> f a -> f (b -> c)
```

There is no way to chain `fmap` now.

2. Composing `fmap`s. What is the data type of `fmap . fmap`

Recall that `(.) :: (b -> c) -> (a -> b) -> (a -> c)`. Let's do some algebraic substitution:

```haskell
(.) :: (b -> c) -> (a -> b) -> (a -> c)
fmap' :: (Functor f1) => (x -> y) -> (f2 x -> f2 y)
fmap :: (Functor f2) => (z -> w) -> (f1 z -> f1 w)
-- fmap' . fmap
-- (x -> y) -> (f2 x -> f2 y) == (b -> c)
-- (z -> w) -> (f1 z -> f1 w) == (a -> b)
-- =>
-- a == (z -> w)
-- b == (f1 z -> f1 w) == (x -> y)
--   =>
--   x == f1 z
--   y == f1 w
-- c == (f2 x -> f2 y)
--     = (f2 (f1 z) -> f2 (f1 w))

-- fmap' . fmap :: a -> c
--               = (z -> w) -> (f2 (f1 z) -> f2 (f1 w))
fmap . fmap :: (Functor f1, Functor f2) => (z -> w) -> (f2 (f1 z) -> f2 (f1 w))
```

Let's compose it to one more level `fmap . fmap . fmap`. Note that `(.)` is `infixr 9` means it takes a higher priority just after function application and more crucially, it associates to right

So,

```haskell
-- fmap . fmap . fmap == fmap . (fmap . fmap)
fmap :: (Functor f3) => (x -> y) -> (f3 x -> f3 y)
fmap . fmap :: (Functor f1, Functor f2) => (z -> w) -> (f2 (f1 z) -> f2 (f1 w))

-- (.)) :: (b -> c)                       -> (a -> b)                                   -> (a -> c)
--         ((x -> y) -> (f3 x -> f3 y))   -> ((z -> w) -> (f2 (f1 z) -> f2 (f1 w)))     -> result

-- (x -> y) == (f2 (f1 z) -> f2 (f1 w))
--    => x == f2 (f1 z), y = f2 (f1 w)

-- fmap . (fmap . fmap) :: (a -> c) = (z -> w) -> (f3 x -> f3 y)
--                                  = (z -> w) -> (f3 (f2 (f1 z) -> f3 (f2 (f1 w)))
fmap . fmap . fmap :: (Functor f1, Functor f2, Functor f3) => (z -> w) -> f3 (f2 (f1 z)) -> f3 (f2 (f1 w))
```

This is beautiful. Composing `fmap`s wrap contexts on top of contexts. Or viewed in a different way, for a nested structure of `n` levels (given each of those structures satisfy `Functor`), composing `fmap` n times can apply within the embedded values, preserving the structure.

For example:

```haskell
arr = [[1,2,3], [2,3,4], [3,4,5]]
arr1 = (fmap . fmap) (*2) arr -- transforms every integer by multiplying by 2, **preserving** the 2D list
```

# Applicatives

```haskell
class Functor f => Applicative f where
    pure :: a -> f a
    (<*>) :: f (a -> b) -> f a -> f b
    liftA2 :: (a -> b -> c) -> f a -> f b -> f c
    (*>) :: f a -> f b -> f b
    (<*) :: f a -> f b -> f a
    {-# MINIMAL pure, ((<*>) | liftA2) #-}
```

1. Applicatives extend over curried functions. Why? Because `(->)` is associates from right.

Let `f1 :: a -> b -> c`. If we type match with `a -> b`, we get, `f1 :: a -> (b -> c)`. Thus 
```haskell
(<*>) :: f (a -> b -> c) -> f a -> f (b -> c)
```

2. `<*>` and `liftA2` are _functionally_ equivalent.

> A curried function (in a context) is applied with a value (in the same context) to get another curried function (in the same context).

3. Implement `liftA2` using `<*>`

- `liftA2` takes in a function without context i.e., we need to apply `pure`

```haskell
liftA2' :: (a -> b -> c) -> f a -> f b -> f c
liftA2' f a b = pure f <*> a <*> b
```

4. `liftA*` functions

```haskell
-- Control.Applicative module
liftA :: (Applicative f) => (a -> b) -> f a -> f b
liftA3 :: (Applicative f) => (a -> b -> c -> d) -> f a -> f b -> f c -> f d
```
