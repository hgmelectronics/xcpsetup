#ifndef MULTILIST_H
#define MULTILIST_H

#include <type_traits>
#include <boost/utility.hpp>
#include <QObject>
#include <QAbstractListModel>
#include <unordered_set>
#include <QList>
#include <QMouseEvent>
#include "libxconfproto_global.h"

/**
 * Model and element-wrapper classes for a list view that allows multiple objects to be selected.
 * After https://wiki.qt.io/Multi-selection-lists-in-Python-with-QML.
 */

/*
    // Example QML for the list view

    ListView {
        id: testing
        width: 500
        height: 400
        model: multiselectListModel // global property created in C++
        controller: MultiselectListController

        delegate: Component {
            Rectangle {
                width: testing.width
                height: 30
                color: model.wrapper.selected ? "#00B8F5" : "#EEE"
                Text {
                    elide: Text.ElideRight
                    text: model.wrapper.displayText
                    color: model.wrapper.selected ? "white" : "black"
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        leftMargin: 5
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        controller.clicked(mouse, multiselectListModel, model.wrapper)
                    }
                }
            }
        }
    }
*/

class LIBXCONFPROTOSHARED_EXPORT MultiselectListWrapper : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString displayText READ displayText WRITE setDisplayText NOTIFY displayTextChanged)
    Q_PROPERTY(bool selected READ selected WRITE setSelected NOTIFY selectedChanged)
    Q_PROPERTY(bool clickedLast READ clickedLast WRITE setClickedLast NOTIFY clickedLastChanged)
    Q_PROPERTY(QObject *obj READ obj NOTIFY objChanged)
public:
    explicit MultiselectListWrapper(QObject *parent = 0);
    virtual ~MultiselectListWrapper();
    QString displayText() const;
    void setDisplayText(QString text);
    bool selected() const;
    void setSelected(bool selected);
    bool clickedLast() const;
    void setClickedLast(bool clickedLast);
    QObject * obj() const;
    void setObj(QObject *obj);
signals:
    void displayTextChanged();
    void selectedChanged();
    void clickedLastChanged();
    void objChanged();
private:
    QString mDisplayText;
    bool mSelected, mClickedLast;
    QObject *mObj;
};

Q_DECLARE_METATYPE(MultiselectListWrapper *)

class LIBXCONFPROTOSHARED_EXPORT MultiselectListModel : public QAbstractListModel
{
    Q_OBJECT
public:
    explicit MultiselectListModel(QObject *parent = 0);
    virtual ~MultiselectListModel();
    int rowCount(const QModelIndex & parent = QModelIndex()) const;
    QHash<int, QByteArray> roleNames() const;
    QList<MultiselectListWrapper *> &list();
    std::unordered_set<MultiselectListWrapper *> checked();
    QVariant data(const QModelIndex &index, int role) const;
    QVariant headerData(int section, Qt::Orientation orientation, int role) const;
private:
    QList<MultiselectListWrapper *> mList;
};

class LIBXCONFPROTOSHARED_EXPORT MultiselectListController : public QObject
{
    Q_OBJECT
public:
    explicit MultiselectListController(QObject *parent = 0);
    virtual ~MultiselectListController();
public slots:
    void clicked(int modifiers, MultiselectListModel *model, MultiselectListWrapper *wrapper);
};

#endif // MULTILIST_H
