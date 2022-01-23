open Coin

let get_config_json path = Yojson.Basic.from_file path

let json_to_coin json =
  let open Yojson.Basic.Util in
  let symbol = json |> member "symbol" |> to_string |> String.uppercase_ascii in 
  let price = json |> member "price" |> to_float in
  let currency = json |> member "currency" |> to_string in
  Coin(symbol, price, currency)

  let get_coin_list json = 
  let open Yojson.Basic.Util in
  let coin_list = json |> member "coins" |> to_list in
  List.map json_to_coin coin_list