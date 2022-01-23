let read_coins_to_track path = 
  let json = Yojson.Basic.from_file path in
  let open Yojson.Basic.Util in
  let coin_list = json |> member "coins" |> to_list |> filter_string in
  coin_list