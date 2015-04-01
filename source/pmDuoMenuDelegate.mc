using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;

class pmDuoMenuDelegate extends Ui.MenuInputDelegate {

    function onMenuItem(item) {
        if (item == :item_1) {
            App.getApp().restartEvent();
        } else if (item == :item_2) {
            Sys.println("Configure");
        }
    }

}