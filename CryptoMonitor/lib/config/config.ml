open Coin

let get_config_json path = Yojson.Basic.from_file path

let validate_coin = function
  | Inapplicable   -> true
  | Coin (symbol, _, currency, _,
          _, applicable, _) ->
      ((symbol != "" || currency != "") && applicable)

let fix_coin coin = 
  if validate_coin coin then coin else Inapplicable

let choose_triggerer s =
  let uppered = String.uppercase_ascii s in
  if uppered = "PROFIT" then Profit
  else if uppered = "PRICE_AND_PROFIT" then PriceAndProfit
  else Price  

let json_to_coin json =
  let open Yojson.Basic.Util in
  let symbol = 
    match json |> member "symbol" |> to_string_option with
      | Some v -> String.uppercase_ascii v
      | None   -> ""
  in 
  let target_price = 
    match json |> member "price" |> to_float_option with
      | Some v -> v
      | None   -> 0.0
  in
  let currency = 
    match json |> member "currency" |> to_string_option with
      | Some v -> String.uppercase_ascii v
      | None   -> ""
  in
  let pocket =
    match json |> member "pocket" |> to_float_option with
      | Some v -> v
      | None   -> 0.0
  in
  let target_profit =
    match json |> member "targetProfit" |> to_float_option with
      | Some v -> v
      | None   -> 0.0
  in
  let applicable =
    match json |> member "applicable" |> to_bool_option with
      | Some v -> v
      | None   -> true
  in
  let notification_triggerer =
    match json |> member "notificationTriggerer" |> to_string_option with
      | Some v -> choose_triggerer v
      | None   -> Price
  in
  fix_coin (Coin(symbol, target_price, currency, pocket,
                target_profit, applicable, notification_triggerer))

let get_coin_list json = 
  let open Yojson.Basic.Util in
  let coin_list = json |> member "coins" |> to_list in
  coin_list

let get_interval json =
  let open Yojson.Basic.Util in
  let interval = json |> member "interval" |> to_int_option in
  interval