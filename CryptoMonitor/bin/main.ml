open Lwt
open Cohttp_lwt_unix
open Core
open Notifier
open Config

let body symbol =
  Client.get (Uri.of_string ("https://min-api.cryptocompare.com/data/price?fsym=" ^ symbol ^ "&tsyms=USD")) >>= fun (_, body) ->
  body |> Cohttp_lwt.Body.to_string >|= fun body ->
  body

let () =
  List.iter (read_coins_to_track "config.json") ~f:(fun sym ->
  let body = Lwt_main.run (body sym) in
  let json = Yojson.Basic.from_string body in
  let open Yojson.Basic.Util in
  try (let price = json |> member "USD" |> to_float in
        price_drop sym price "USD") with
    _ -> coin_not_found sym)