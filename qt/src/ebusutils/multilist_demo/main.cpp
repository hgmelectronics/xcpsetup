#include <QApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include <MultiselectList.h>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    qmlRegisterType<MultiselectListWrapper>("com.ebus.examples.multilist_demo", 1, 0, "MultiselectListWrapper");
    qmlRegisterType<MultiselectListModel>("com.ebus.examples.multilist_demo", 1, 0, "MultiselectListModel");
    qmlRegisterType<MultiselectListController>("com.ebus.examples.multilist_demo", 1, 0, "MultiselectListController");

    static const std::vector<std::pair<QString, QString> > ENTRIES =
    {
        {"Beautiful is better than ugly.", "fnord"},
        {"Explicit is better than implicit.", "foo"},
        {"Simple is better than complex.", "bar"},
        {"Complex is better than complicated.", "baz"},
        {"Flat is better than nested.", "quux"},
        {"Sparse is better than dense.", "corge"},
        {"Readability counts.", "grault"},
        {"Special cases aren't special enough to break the rules.", "garply"},
        {"Although practicality beats purity.", "waldo"},
        {"Errors should never pass silently.", "fred"},
        {"Unless explicitly silenced.", "plugh"},
        {"In the face of ambiguity, refuse the temptation to guess.", "xyzzy"},
        {"There should be one-- and preferably only one --obvious way to do it.", "thud"},
        {"Although that way may not be obvious at first unless you're Dutch.", "spam"},
        {"Now is better than never.", "ham"},
        {"Although never is often better than *right* now.", "eggs"},
        {"If the implementation is hard to explain, it's a bad idea.", "norf"},
        {"If the implementation is easy to explain, it may be a good idea.", "wibble"},
        {"Namespaces are one honking great idea -- let's do more of those!", "wobble"}
    };
    MultiselectListModel *model = new MultiselectListModel();
    for(auto &entry : ENTRIES)
    {
        MultiselectListWrapper *wrap = new MultiselectListWrapper();
        wrap->setDisplayText(entry.first);
        wrap->setSelected(false);
        wrap->setObj(NULL);
        model->list().push_back(wrap);
    }

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("multiselectListModel", model);
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
