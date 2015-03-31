using Toybox.WatchUi as Ui;
using Toybox.System as Sys;

class pmDuoMenuDelegate extends Ui.MenuInputDelegate {

    function onMenuItem(item) {
        if (item == :item_1) {
            pmDuoView.restartDuathlon();
        } else if (item == :item_2) {
            Sys.println("item 2");
        }
    }

}