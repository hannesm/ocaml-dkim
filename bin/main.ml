let () = Printexc.record_backtrace true

module Caml_flow : Dkim.FLOW with type flow = in_channel = struct
  type flow = in_channel

  let input = Pervasives.input
end

let () =
  match Dkim.extract_dkim stdin (module Caml_flow) with
  | Error (`Msg err) -> Fmt.epr "Retrieve an error: %s.\n%!" err
  | Ok (prelude, _, values) ->
    let values = List.map
        (fun (value) -> match Dkim.post_process_dkim value with
           | Ok value -> value
           | Error (`Msg err) -> invalid_arg err)
        values in
    Fmt.pr "%a.\n%!" Fmt.(Dump.list Dkim.pp_dkim) values ;
    let dkim = List.hd values in
    let Dkim.H (k, h) = Dkim.digest_body stdin (module Caml_flow) (prelude, dkim) in
    let Dkim.H (k', h') = Dkim.expected dkim in
    match Dkim.equal_hash k k' with
    | Some Dkim.Refl.Refl ->
      if Digestif.equal k h h'
      then Fmt.pr "Body is verified.\n%!"
      else Fmt.pr "Body is alterated (expected: %a, provided: %a).\n%!"
          (Digestif.pp k) h'
          (Digestif.pp k) h
    | None -> assert false
