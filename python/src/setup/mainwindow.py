'''
Created on Jun 15, 2013

@author: gcardwel
'''

# void MainWindow::parseJSON()
# {
#     QFile *f = new QFile("C:/users/gcardwel/desktop/Controls.json");
#     QtJson::Json parser;
#     bool ok;
#     f->open(QIODevice::ReadOnly);
#     QVariantMap result = parser.parse(f, &ok).toMap();
#     if (!ok) {
#         QMessageBox::critical(0,"Parse failed","parsing false");
#         return;
#     }
#     QList<QVariant> items = result["items"].toList();
#     //    QWidget * widget = ui->scrollAreaWidgetContents;
# 
#     //    QVBoxLayout * layout = new QVBoxLayout();
# 
#     ui->engine->setLayout(new QGridLayout());
#     ui->vehicle->setLayout(new QGridLayout());
#     ui->transmission->setLayout(new QGridLayout());
#     ui->accessories->setLayout(new QGridLayout());
# 
#     foreach (QVariant item, items) {
#         QVariantMap map = item.toMap();
#         QString name = map["name"].toString();
#         QString type = map["type"].toString();q
#         QString parameter = map["parameter"].toString();
#         QVariant vSection = map["section"];
#         if (!vSection.isValid()) continue;
#         QString section = vSection.toString();
#         QWidget * parent = this->findChild<QWidget *>(section);
#         QLayout * layout = parent->layout();
#         QGroupBox * gb = new QGroupBox(parameter);
#         if (type.compare("EnumControl",Qt::CaseInsensitive)==0)
#         {
#             QVBoxLayout * vb = new QVBoxLayout();
#             QComboBox * cb = new QComboBox();
#             cb->addItem("something");
#             vb->addWidget(cb);
#             gb->setLayout(vb);
#         }
#         else if (type.compare("CountControl",Qt::CaseInsensitive)==0)
#         {
#             QVBoxLayout * vb = new QVBoxLayout();
#             gb->setLayout(vb);
#             QSpinBox * sb = new QSpinBox();
#             QVariant min = map["min"];
#             QVariant max = map["max"];
#             QVariant step = map["step"];
#             if (min.isValid()) sb->setMinimum(min.toInt());
#             if (max.isValid()) sb->setMaximum(max.toInt());
#             if (step.isValid()) sb->setSingleStep(step.toInt());
#             vb->addWidget(sb);
#             gb->setLayout(vb);
# 
#         }
#         else if (type.compare("NumberControl",Qt::CaseInsensitive)==0)
#         {
#             QVBoxLayout * vb = new QVBoxLayout();
#             gb->setLayout(vb);
#             QDoubleSpinBox * sb = new QDoubleSpinBox();
#             QVariant min = map["min"];
#             QVariant max = map["max"];
#             QVariant step = map["step"];
#             sb->setDecimals(2);
#             if (min.isValid()) sb->setMinimum(min.toInt()/100.0);
#             if (max.isValid()) sb->setMaximum(max.toInt()/100.0);
#             if (step.isValid()) sb->setSingleStep(step.toInt()/100.0);
#             vb->addWidget(sb);
#             gb->setLayout(vb);
# 
#         }
#         else
#         {
#             QVBoxLayout * vb = new QVBoxLayout();
#             QLabel *label = new QLabel("Not implemented");
#             vb->addWidget(label);
#             gb->setLayout(vb);
#         }
#         layout->addWidget(gb);
# 
#     }
# }
# 
# void MainWindow::setupPressure()
# {
# //    mPressureTable = new PressureTable();
# //    for(int i=0; i<100; i+=10)
# //    {
# //        mPressureTable->setPressure(i,i);
# //    }
# //    ui->tableView->setModel(new PressureTableModel(mPressureTable,this));
# //    ui->tableView->resizeColumnsToContents();
# 
# }
# 
# 
# MainWindow::MainWindow(QWidget *parent) :
#         QMainWindow(parent),
#         ui(new Ui::MainWindow)
# {
#     ui->setupUi(this);
#     parseJSON();
# //    setupPressure();
#      EnumControl * c = new EnumControl();
#      c->setName("something");
#      c->setDescription("something wicked this way comes.");
#      QVariantMap m;
#      m["one"] = QVariant(1);
#      m["two"] = QVariant(2);
#      m["three"] = QVariant(3);
#      c->setValues(m);
#      ui->engine->layout()->addWidget(c);
#  }
# 
# 
# 
# 
# MainWindow::~MainWindow()
# {
#     delete ui;
# }
# 
# void MainWindow::changeEvent(QEvent *e)
# {
#     QMainWindow::changeEvent(e);
#     switch (e->type()) {
#     case QEvent::LanguageChange:
#         ui->retranslateUi(this);
#         break;
#     default:
#         break;
#     }
# }

class MainWindow(object):
    '''
    classdocs
    '''


    def __init__(selfparams):
        '''
        Constructor
        '''
        