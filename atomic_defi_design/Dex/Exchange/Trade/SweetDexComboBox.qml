import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.0
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Controls.Universal 2.15

import Qaterial 1.0 as Qaterial

import "../../Components"
import App 1.0
import Dex.Themes 1.0 as Dex

ComboBox
{
    id: control

    contentItem: DexComboBoxLine
    {
        id: line

        property int update_count: 0
        property var prev_details

        function forceUpdateDetails()
        {
            console.log("Portfolio item data changed, force-updating the selected ticker details!")
            ++update_count
        }

        padding: 10
        details:
        {
            const idx = combo.currentIndex

            if(idx === -1) return prev_details

            // Update count triggers the change for auto-update
            const new_details =
                              {
                update_count:           line.update_count,
                ticker:                 model.data(model.index(idx, 0), 257),
                name:                   model.data(model.index(idx, 0), 259),
                balance:                model.data(model.index(idx, 0), 260),
                main_currency_balance:  model.data(model.index(idx, 0), 261)
            }

            prev_details = new_details

            return new_details
        }

        Component.onCompleted: portfolio_mdl.portfolioItemDataChanged.connect(forceUpdateDetails)
        Component.onDestruction: portfolio_mdl.portfolioItemDataChanged.disconnect(forceUpdateDetails)
    }

    height: 80

    background: DefaultRectangle
    {
        color: Dex.CurrentTheme.floatingBackgroundColor
        radius: 10
    }

    // Each dropdown item
    delegate: ItemDelegate
    {
        Universal.accent: control.lineHoverColor
        width: control.width
        highlighted: control.highlightedIndex === index
        contentItem: DexComboBoxLine { details: model }
        z: 5
    }

    // Dropdown itself
    popup: Popup
    {
        id: popup

        readonly property double max_height: 450//control.Window.height - bottomMargin - mapToItem(control.Window.contentItem, x, y).y

        width: control.width
        height: Math.min(contentItem.implicitHeight, popup.max_height)
        z: 4
        y: control.height - 1
        bottomMargin: 20
        padding: 1
        rightMargin: 5

        contentItem: ColumnLayout
        {
            anchors.rightMargin: 5

            // Search input
            SearchField
            {
                id: tickerSearchField

                function reset()
                {
                    textField.text = ""
                    renewIndex()
                }

                Layout.preferredWidth: parent.width - 10
                Layout.preferredHeight: 30
                Layout.alignment: Qt.AlignHCenter

                color: Dex.CurrentTheme.backgroundColor

                textField.font.pixelSize: 16
                textField.onTextChanged:
                {
                    ticker_list.setFilterFixedString(textField.text)
                    renewIndex()
                }

                Keys.onDownPressed: control.incrementCurrentIndex()
                Keys.onUpPressed: control.decrementCurrentIndex()
                Keys.onPressed:
                {
                    if (event.key === Qt.Key_Return)
                    {
                        if (control.count > 0) control.currentIndex = 0;
                        popup.close();
                        event.accepted = true;
                    }
                }

                Connections
                {
                    target: popup
                    function onOpened()
                    {
                        tickerSearchField.reset();
                        tickerSearchField.forceActiveFocus();
                    }
                    function onClosed() { tickerSearchField.reset() }
                }
            }

            DefaultListView
            {
                Layout.maximumHeight: popup.max_height - 100
                Layout.fillWidth: true

                model: control.popup.visible ? control.delegateModel : null
                currentIndex: control.highlightedIndex

                DefaultMouseArea
                {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton
                }
            }
        }

        background: DefaultRectangle
        {
            width: parent.width
            y: -5
            height: parent.height + 10
            radius: 10
        }
    }

    indicator: Column
    {
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 8
        spacing: -12

        Qaterial.Icon
        {
            width: 30
            height: 30
            color: Dex.CurrentTheme.comboBoxArrowsColor
            icon: Qaterial.Icons.chevronDown
        }
    }
}
