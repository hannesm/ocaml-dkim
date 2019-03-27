type 'a t = 'a option

let some x = Some x

let map f = function
  | Some x -> Some (f x)
  | None -> None

let value ~default = function
  | Some x -> x
  | None -> default
