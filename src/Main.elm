port module Main exposing(main)

import Browser
import Html exposing (Html, div, img, input, span, text)
import Html.Events exposing (onClick, onInput)
import Html.Attributes as A exposing (src, style, type_, max, min, step, value)
import Media exposing (PortMsg, newVideo, videoWithEvents, play, pause, seek)
import Media.Source exposing (source)
import Media.State exposing (currentTime, duration, PlaybackStatus(..), playbackStatus, PlaybackError(..))

main: Program () Model Msg
main =
  Browser.element { init = init, update = update, view = widget, subscriptions = always Sub.none }

port outbound : PortMsg -> Cmd msg
port console : String -> Cmd msg

-- MODEL

type alias Model =
  { state: Media.State
  , url: String
  , seeked: Seeked
  }

type Seeked
  = Auto
  | FeatureNotABug Float

init : flags -> (Model, Cmd Msg)
init _ =
  ( { state = newVideo "widgetVideo"
    , url = "https://cdn.altrulabs.com/uploads/production/videos/video-12965/video_12965_cno31x1nzLI7I2V3I89vAQ.mp4"
    , seeked = Auto
    }
  , Cmd.none
  )


-- UPDATE

type Msg
  = ToggleState
  | UpdateState Media.State
  | Seek String

click: Media.State -> Cmd Msg
click state = case playbackStatus state of
  Paused -> play state outbound
  Playing -> pause state outbound
  Loading -> Cmd.none
  Buffering -> pause state outbound
  Ended -> play state outbound
  PlaybackError _ -> Cmd.batch [console "playback error", play state outbound]

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    ToggleState -> (model, click model.state)
    UpdateState state ->
      ( {model|state=state}
      , Cmd.none
      )
    Seek value -> case String.toFloat value of
      Just rot -> case model.seeked of
        FeatureNotABug _ -> ({model|seeked = FeatureNotABug rot}, Cmd.none)
        Auto ->
          let
            r = currentTime model.state / duration model.state * normTot model.state
          in
          ({model|seeked = FeatureNotABug r}, Cmd.none)
      Nothing -> (model, Cmd.none)
    {-
    Seek value -> case String.toFloat value of
      Just seconds -> (model, seek model.state seconds outbound)
      Nothing -> (model, Cmd.none)
    -}


-- VIEW

widget: Model -> Html Msg
widget model = 
  div
    [ style "display" "inline-flex"
    , style "position" "fixed"
    , style "bottom" "0"
    , style "right" "45px"
    , style "border-style" "solid"
    , style "border-width" "5px"
    , style "border-radius" "45px"
    , style "background-color" "lightblue"
    , style "padding" "20px 20px 5px 5px"
    ]
    [ span
      [ style "align-self" "flex-end" ]
      [ toggleButton model.state ]
    , div
      [ style "display" "inline-flex"
      , style "flex-flow" "column"
      ]
      [ vid model
      , span
        [ style "padding" "20px 0 0" ]
        [ seeker model.seeked model.state ]
      ]
    ]

vid: Model -> Html Msg
vid model = div
  [ style "transform" "rotate(-45deg)"
  , style "display" "inline-block"
  , style "overflow" "hidden"
  , style "width" "100px"
  ]
  [ videoWithEvents model.state UpdateState
    [ onClick ToggleState
    , style "width" "100px"
    , style "transform" <|
        scale (factor model.seeked model.state)
        ++
        rotate (factor model.seeked model.state)
    ]
    [ source model.url []
    ]
  ]

toggleButton: Media.State -> Html Msg
toggleButton state = span
  [ onClick ToggleState
  , style "padding" "5px"
  ]
  [ case playbackStatus state of
    Playing -> img
      [ src "https://upload.wikimedia.org/wikipedia/commons/f/fa/Octicons-playback-pause.svg"
      , style "width" "45px"
      ] []
    Paused -> img
      [ src "https://upload.wikimedia.org/wikipedia/commons/7/7b/Octicons-playback-play.svg"
      , style "width" "45px"
      ] []
    Ended -> img
      [ src "https://upload.wikimedia.org/wikipedia/commons/7/7b/Octicons-playback-play.svg"
      , style "width" "45px"
      ] []
    Loading -> img
      [ src "https://upload.wikimedia.org/wikipedia/commons/f/fa/Octicons-playback-pause.svg"
      , style "width" "45px"
      , style "transform" "rotate(90deg)"
      ] []
    Buffering -> img
      [ src "https://upload.wikimedia.org/wikipedia/commons/f/fa/Octicons-playback-pause.svg"
      , style "width" "45px"
      , style "transform" "rotate(90deg)"
      ] []
    PlaybackError _ -> text "Error"
  ]

seeker: Seeked -> Media.State -> Html Msg
seeker seeked state = case seeked of
  Auto ->
    input
    [ type_ "range"
    , value <| String.fromFloat <| currentTime state
    , A.min "0"
    , A.max <| String.fromFloat <| duration state
    , step "0.1"
    , onInput Seek
    ] []
  FeatureNotABug rot ->
    input
    [ type_ "range"
    , value <| String.fromFloat rot
    , A.min "0"
    , A.max <| String.fromFloat <| normTot state
    , step "0.1"
    , onInput Seek
    ] []

normTot: Media.State -> Float
normTot state = Basics.min 5 <| duration state

normCur: Media.State -> Float
normCur state = Basics.max 0.001 <| Basics.min (normTot state) (currentTime state)

factor: Seeked -> Media.State -> Float
factor seeked state = case seeked of
  Auto ->
    normCur state / normTot state
  FeatureNotABug rot -> rot / normTot state

scale: Float -> String
scale s = "scale("++ (String.fromFloat <| 2 - s) ++ ")"

rotate: Float -> String
rotate r = "rotate("++(String.fromFloat <| 45 - 45 * r)++"deg)"

