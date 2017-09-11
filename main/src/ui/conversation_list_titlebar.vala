using Gtk;

using Dino.Entities;

namespace Dino.Ui {

[GtkTemplate (ui = "/im/dino/conversation_list_titlebar.ui")]
public class ConversationListTitlebar : Gtk.HeaderBar {

    public signal void conversation_opened(Conversation conversation);

    [GtkChild] private MenuButton add_button;
    [GtkChild] public ToggleButton search_button;

    private StreamInteractor stream_interactor;

    public ConversationListTitlebar(StreamInteractor stream_interactor, Window window) {
        this.stream_interactor = stream_interactor;

        custom_title = new Label("Dino") { visible = true, hexpand = true, xalign = 0 };
        custom_title.get_style_context().add_class("title");

        create_add_menu(window);
    }

    private void create_add_menu(Window window) {
        Util.Shortcuts.singleton.enable_action("add_chat").activate.connect(() => {
            AddConversation.Chat.Dialog add_chat_dialog = new AddConversation.Chat.Dialog(stream_interactor, stream_interactor.get_accounts());
            add_chat_dialog.set_transient_for(window);
            add_chat_dialog.title = _("Start Chat");
            add_chat_dialog.ok_button.label = _("Start");
            add_chat_dialog.selected.connect((account, jid) => {
                Conversation conversation = stream_interactor.get_module(ConversationManager.IDENTITY).create_conversation(jid, account, Conversation.Type.CHAT);
                stream_interactor.get_module(ConversationManager.IDENTITY).start_conversation(conversation, true);
                conversation_opened(conversation);
            });
            add_chat_dialog.present();
        });

        Util.Shortcuts.singleton.enable_action("add_conference").activate.connect(() => {
            AddConversation.Conference.Dialog add_conference_dialog = new AddConversation.Conference.Dialog(stream_interactor);
            add_conference_dialog.set_transient_for(window);
            add_conference_dialog.conversation_opened.connect((conversation) => conversation_opened(conversation));
            add_conference_dialog.present();
        });

        Builder builder = new Builder.from_resource("/im/dino/menu_add.ui");
        MenuModel menu = builder.get_object("menu_add") as MenuModel;
        add_button.set_menu_model(menu);
    }
}

}
