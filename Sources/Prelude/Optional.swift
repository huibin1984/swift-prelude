public func optional<A, B>(_ default: B) -> (@escaping (A) -> B) -> (A?) -> B {
  return { a2b in
    { a in
      a.map(a2b) ?? `default`
    }
  }
}

public func coalesce<A>(with default: A) -> (A?) -> A {
  return optional(`default`) <| id
}


extension Optional {
  public func `do`(_ f: (Wrapped) -> Void) {
    if let x = self { f(x) }
  }
}

// MARK: - Functor

extension Optional {
  public static func <¢> <A>(f: (Wrapped) -> A, x: Optional) -> A? {
    return x.map(f)
  }
}

public func map<A, B>(_ a2b: @escaping (A) -> B) -> (A?) -> B? {
  return { a in
    a2b <¢> a
  }
}

// MARK: - Apply

extension Optional {
  public func apply<A>(_ f: ((Wrapped) -> A)?) -> A? {
    // return f.flatMap(self.map) // https://bugs.swift.org/browse/SR-5422
    guard let f = f, let a = self else { return nil }
    return f(a)
  }

  public static func <*> <A>(f: ((Wrapped) -> A)?, x: Optional) -> A? {
    return x.apply(f)
  }
}

public func apply<A, B>(_ a2b: ((A) -> B)?) -> (A?) -> B? {
  return { a in
    a2b <*> a
  }
}

// MARK: - Applicative

public func pure<A>(_ a: A) -> A? {
  return .some(a)
}

// MARK: - Bind/Monad

extension Optional {
  static public func >>- <A>(x: Optional, f: (Wrapped) -> A?) -> A? {
    return x.flatMap(f)
  }
}

public func flatMap<A, B>(_ a2b: @escaping (A) -> B?) -> (A?) -> B? {
  return { a in
    a >>- a2b
  }
}

// MARK: - Semigroup

extension Optional where Wrapped: Semigroup {
  public static func <> (lhs: Optional, rhs: Optional) -> Optional {
    return curry(<>) <¢> lhs <*> rhs
  }
}

// MARK: - Foldable/Traversable

extension Optional {
  public func foldMap<M: Monoid>(_ f: @escaping (Wrapped) -> M) -> M {
    return self.map(f) ?? M.empty
  }
}

public func foldMap<A, M: Monoid>(_ f: @escaping (A) -> M) -> (A?) -> M {
  return { xs in
    xs.foldMap(f)
  }
}
