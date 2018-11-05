module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode as Decode
import Url.Builder as Url


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


type alias Model =
    { topic : String, url : String }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model "" "https://imgplaceholder.com/900x300/cccccc/757575/fa-optin-monster"
    , Cmd.none
    )


type Msg
    = Load
    | Change String
    | NewImage (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Load ->
            ( model, getImage model.topic )

        Change value ->
            ( { model | topic = value }, Cmd.none )

        NewImage result ->
            case result of
                Ok value ->
                    ( { model | url = value }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


view : Model -> Html Msg
view model =
    div [ class "container has-text-centered" ]
        [ h1 [ class "title" ] [ text model.url ]
        , input
            [ type_ "text"
            , class "input is-large has-text-centered"
            , value model.topic
            , onInput Change
            ]
            []
        , figure [ class "image is-3by1" ]
            [ img [ src model.url ] []
            ]
        , button
            [ class "button is-success is-large is-fullwidth"
            , onClick Load
            ]
            [ text "Cargar!" ]
        ]



-- HELLPERS


getImage : String -> Cmd Msg
getImage topic =
    Http.send NewImage (Http.get (toImageUrl topic) imageDecoder)


toImageUrl : String -> String
toImageUrl topic =
    Url.crossOrigin "https://api.giphy.com"
        [ "v1", "gifs", "random" ]
        [ Url.string "api_key" "dc6zaTOxFJmzC"
        , Url.string "tag" topic
        ]


imageDecoder : Decode.Decoder String
imageDecoder =
    Decode.field "data" (Decode.field "image_url" Decode.string)
