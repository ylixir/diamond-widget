window.diamondWidget = {
    init() {
	MediaApp.Modify.timeRanges();
	/* Adds the "asArray getter to the TimeRanges object prototype, allowing us to decode the media element state without using Native/Kernel Code */
	MediaApp.Modify.tracks();
	/* Adds the "mode" setter and getter to the HTMLTrack object prototype, letting us show/hide/disable text tracks from the view function. */
	MediaApp.Elements.defineMediaCapture();

	const elmement = document.createElement('div')
	document.body.appendChild(elmement)
	let elmApp = Elm.Main.init({node:elmement});

	/* Subscribe to our port and pass it the default portHandler(msg) function from "/Port/mediaApp.js" */
	elmApp.ports.outbound.subscribe(MediaApp.portHandler);
	elmApp.ports.console.subscribe(console.log);
    }
}
window.addEventListener("DOMContentLoaded", window.diamondWidget.init)
