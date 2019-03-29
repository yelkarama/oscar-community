/* Code taken from https://jsfiddle.net/Daniel_Hug/pvk6p/ */
var timer;
var startPause;
var clear;

var startTime;
var chartTimer = {
    "milliseconds": 0,
    "seconds": 0,
    "minutes": 0,
    "hours": 0
};
var timeoutId;
var pauseTimer = {
    "milliseconds": 0,
    "seconds": 0,
    "minutes": 0,
    "hours": 0
};
var time = "";
var paused = false;

function initTimer() {
    timer = document.getElementById("timer__display");
    startPause = document.getElementById("timer__start-pause");
    clear = document.getElementById("timer__restart");


    timer.onclick = pasteTimer;
    startPause.onclick = startPauseTimer;
    clear.onclick = resetTimer;


    startTime = new Date().toLocaleTimeString();
    createTimer();
}

/* Update function used from RobG's answer at https://stackoverflow.com/questions/41639780/js-timer-function-with-dynamic-interval-getting-off-by-one-secondout-of-sync */
function update(fn, period, hold) {
    var buffer = 20;
    if (!hold) fn();
    hold = false;
    var now = new Date();
    var delayToNext = period - ((Date.now() - now.getTimezoneOffset() * 6e4) % period);
    if (delayToNext > 1000) {
        delayToNext *= .9;
        hold = true;
    }
    clearTimeout(timeoutId);
    timeoutId = setTimeout(function(){
        update(fn, period, hold)
    }, delayToNext + buffer);
}

function add() {
    var timerToIncrement = paused ? pauseTimer : chartTimer;

    timerToIncrement.seconds++;
    if (timerToIncrement.seconds >= 60) {
        timerToIncrement.seconds = 0;
        timerToIncrement.minutes++;
        if (timerToIncrement.minutes >= 60) {
            timerToIncrement.minutes = 0;
            timerToIncrement.hours++;
        }
    }

    if (!paused) {
        time = formatTime(chartTimer.hours, chartTimer.minutes, chartTimer.seconds);
        timer.textContent = time;
    }
}

function createTimer() {
    update(add, 1000, true);
}

/* Start button */
function pasteTimer() {
    var displayText = time + "\n"
        + "Start Time: " + startTime + "\n"
        + "End Time: " + new Date().toLocaleTimeString();

    if (pauseTimer.seconds > 0 || pauseTimer.minutes > 0 || pauseTimer.hours > 0) {
        displayText = displayText + "\n"
            + "Pause Duration: " + formatTime(pauseTimer.hours, pauseTimer.minutes, pauseTimer.seconds);
    }

    pasteToEncounterNote(displayText);
}

/* Pause/Start button */
function startPauseTimer() {
    clearTimeout(timeoutId);
    createTimer();
    paused = !paused;
    startPause.title = paused ? "Play":"Pause";

    startPause.classList.toggle("glyphicon-pause");
    startPause.classList.toggle("glyphicon-play");
}

/* Clear button */
function resetTimer() {
    timer.textContent = "00:00:00";
    chartTimer.seconds = 0; chartTimer.minutes = 0; chartTimer.hours = 0;
    pauseTimer.seconds = 0; pauseTimer.minutes = 0; pauseTimer.hours = 0;
    startTime = new Date().toLocaleTimeString();

}

function formatTime(hours, minutes, seconds) {
    return (hours ? (hours > 9 ? hours : "0" + hours) : "00") + ":" + (minutes ? (minutes > 9 ? minutes : "0" + minutes) : "00") + ":" + (seconds > 9 ? seconds : "0" + seconds);
}