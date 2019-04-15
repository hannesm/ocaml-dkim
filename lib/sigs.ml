module type FUNCTOR = sig type 'a t end

type (+'a, 't) io

type 't state =
  { bind : 'a 'b. ('a, 't) io -> ('a -> ('b, 't) io) -> ('b, 't) io
  ; return : 'a. 'a -> ('a, 't) io }

module type X = sig
  type 'a s
  type t

  external inj : 'a s -> ('a, t) io = "%identity"
  external prj : ('a, t) io -> 'a s = "%identity"
end

module Common = struct
  type t

  external inj : 'a -> 'b = "%identity"
  external prj : 'a -> 'b = "%identity"
end

module Make (T : FUNCTOR) = struct
  type 'a s = 'a T.t
  include Common
end

module type FLOW = sig
  type backend
  type flow

  val input : flow -> bytes -> int -> int -> (int, backend) io
end

module type DNS = sig
  type backend
  type t

  val getaddrinfo : t -> [ `TXT ] -> Domain_name.t -> ((string list, [ `Msg of string ]) result, backend) io
end
