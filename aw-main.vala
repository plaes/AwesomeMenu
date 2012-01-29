/*
 * Simple Awesome WM helper for GNOME session
 *
 * vim: set ts=4 sw=4 tw=0 expandtab:
 */
using Gtk;

#if 0
[DBus (name="org.freedesktop.ConsoleKit.Manager")]
interface ckManagerClient: Object {
    public abstract string GetCurrentSession ()
        throws IOError;
}
[DBus (name="org.freedesktop.Consolekit.Session")]
interface ckSessionClient: Object {
    public abstract void Lock()
        throws IOError;
}
#endif

[DBus (name="org.freedesktop.UPower")]
interface UPowerClient: Object {
    public abstract void Suspend ()
        throws IOError;
}

public class Main {

    class StatusMenu: Window {

        private Menu tray_menu;
        private StatusIcon tray_icon;
        private Dialog dialog;
        private const string[] dbus_UPower = {"org.freedesktop.UPower",
                                              "/org/freedesktop/UPower"};
        private const string[] dbus_ConsoleKit =
                                            {"org.freedesktop.ConsoleKit",
                                             "/org/freedesktop/ConsoleKit"};

        public StatusMenu() {
            tray_icon = new StatusIcon.from_stock(Gtk.Stock.HOME);
            tray_icon.set_tooltip_text("Awesome GNOME");
            tray_icon.set_visible(true);
            init_menu();
            tray_icon.popup_menu.connect(menu_popup);
        }

        public void init_menu() {
            tray_menu = new Menu();

#if 0
            /* TODO: Lock screen */
            var m_lock = new MenuItem.with_label("Lock screen");
            m_lock.activate.connect(menu_lock_clicked);
            tray_menu.append(m_lock);
#endif
            var m_suspend = new MenuItem.with_label("Suspend");
            m_suspend.activate.connect(menu_suspend_clicked);
            tray_menu.append(m_suspend);
#if 0
            var m_shutdown = new MenuItem.with_label("Shutdown");
            m_shutdown.activate.connect(menu_shutdown_clicked);
            tray_menu.append(m_shutdown);

            /* TODO: Shutdown
            * dbus-send --system --dest=org.freedesktop.ConsoleKit.Manager \
            * /org/freedesktop/ConsoleKit/Manager org.freedesktop.ConsoleKit.Manager.Stop
            */
            /* TODO: Reboot
            * dbus-send --system --dest=org.freedesktop.ConsoleKit.Manager \
            * /org/freedesktop/ConsoleKit/Manager org.freedesktop.ConsoleKit.Manager.Restart
            */
            /* TODO: Log out ???*/
#endif
            var m_sep = new SeparatorMenuItem();
            tray_menu.append(m_sep);

            /* About */
            var m_about = new ImageMenuItem.from_stock(Gtk.Stock.ABOUT, null);
            m_about.activate.connect(menu_about_clicked);
            tray_menu.append(m_about);

            /* Quit */
            var m_quit = new ImageMenuItem.from_stock(Gtk.Stock.QUIT, null);
            m_quit.activate.connect(Gtk.main_quit);
            tray_menu.append(m_quit);

            tray_menu.show_all();
        }

        private void menu_suspend_clicked() {
            /* Clean up old dialog */
            if (this.dialog != null)
                this.dialog.destroy();

            /* Create layout widgets */
            var info_label = new Label("");
            info_label.set_markup("<b>Suspend Computer?</b>");

            this.dialog = new Dialog();
            var content_area = this.dialog.get_content_area() as Box;
            content_area.pack_start(info_label, false, false);

            this.dialog.add_button(Stock.CANCEL, ResponseType.CANCEL);
            this.dialog.add_button("Suspend", ResponseType.APPLY);
            this.dialog.set_default_response (ResponseType.CANCEL);

            this.dialog.show_all();
            var result = this.dialog.run();
            switch (result) {
                case ResponseType.APPLY:
                    try {
                        UPowerClient client = Bus.get_proxy_sync (BusType.SYSTEM, dbus_UPower[0], dbus_UPower[1]);
                        client.Suspend();
                    } catch (IOError e) {
                        /* TODO: Show proper error message */
                        stdout.printf ("%s\n", e.message);
                    }
                break;
            }
            this.dialog.destroy();
        }

#if 0
        private void menu_lock_clicked() {
            try {
                ckManagerClient mc = Bus.get_proxy_sync (BusType.SYSTEM, dbus_ConsoleKit[0],
                dbus_ConsoleKit[1] + "/Manager");
                var session = mc.GetCurrentSession();
                ckSessionClient sc = Bus.get_proxy_sync (BusType.SYSTEM, dbus_ConsoleKit[0],
                session);
                sc.Lock();
            } catch (IOError e) {
                stdout.printf ("%s\n", e.message);
            }
        }
#endif

        private void menu_about_clicked() {
            var about = new AboutDialog();
            about.set_version("0.0");
            about.set_program_name("Awesome GNOME");
            about.set_comments("Easy logout/suspend/shutdown utility for Awesome GNOME session.");
            about.set_copyright("Priit Laes");
            about.run();
            about.hide();
        }

        private void menu_popup(uint button, uint time) {
            tray_menu.popup(null, null, null, button, time);
        }

        public static int main(string[] args) {
            Gtk.init(ref args);
            var app = new StatusMenu();
            app.hide();

            Gtk.main();
            return 0;
        }
    }
}
