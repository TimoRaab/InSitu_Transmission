/**
  Spin Coater Control Software

  @author Timo Raab
          University of Konstanz
          Universitätsstraße 10
          78464 Konstanz
          Germany

          Timo.Raab@uni-konstanz.de

  @version v0.6

  Changes in Versions:
  v0.6  -speed of zero is now possible, steps only gets neglected if time is 0
  v0.7  -changed Servo library to superior ServoTimer2
        -Added new spin method to be able to abort the spin runShort
        -Changed run to runNormal
        -Changed string for remote program
            rem[delayValue]_[shortTime](_[speedX]_[time_X]_[accX])ntimes
            rem(+|-)\d+_\d+(_\d+_\d+_\d+)+
*/

// @TODO________________________________________________________________________
/*
 *
 */

// @Upgrade_____________________________________________________________________
/*
 * 
 */

// Libraries____________________________________________________________________

#include <Arduino.h>
#include <LiquidCrystal.h>
#include <Servo.h>
#include <Button.h>
#include <EEPROM.h>


// Definitions__________________________________________________________________

#define TERMINATOR '\n'
#define RARROW  "\x7E"
#define LARROW  "\x7F"
#define VLINE   "\x7C"
String charList[] = {
  " ", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", 
  "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
  "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"
};
unsigned int cListLen = sizeof(charList)/sizeof(charList[0]);


// Magic Numbers________________________________________________________________
// LCD configuration
const byte dispLines = 4;
const byte dispColumns = 20;
const byte rs = 17, en = 18, d0 = 34, d1 = 32, d2 = 30, d3 = 28,
    d4 = 29, d5 = 31, d6 = 33, d7 = 35;
byte currentLine = 0;
byte currentTab = 0;

// ESC configuration
const byte escPin = 8;
const byte escStartPin = 9;

// Button configuration 37 48 39 46 36 38
const byte buttonUp = 36;
const byte buttonDown = 48;
const byte buttonLeft = 46;
const byte buttonRight = 38;
const byte buttonOK = 37;
const byte buttonAbort = 39;

Button bUp = Button(buttonUp);
Button bDown = Button(buttonDown);
Button bLeft = Button(buttonLeft);
Button bRight = Button(buttonRight);
Button bOK = Button(buttonOK);
Button bAbort = Button(buttonAbort);

// LED configuration
const byte ledUp = 40;
const byte ledDown = 49;
const byte ledLeft = 47;
const byte ledRight = 42;
const byte ledOK = 41;
const byte ledAbort = 43;

// Spectrometer configuration
const byte trigger = 10;


// Shutter configuration
const byte shutterPin = 53;
const int shutterOn = 900;    
const int shutterOff = 1300;   
boolean shutterStatus = false;


// Calibration for Speed Control
// calibMethod
//    0   linear interpolation with calib
//    1   2nd order interpolation with fitValues a-c
const unsigned int calibMethod = 1;
const unsigned int calib[2][2] = {
  {1250, 396},
  {2000, 1770}
};

// Values at 25.03.2022
const float fitA = -0.0003921;
const float fitB = 5.867;
const float fitC = -5030;

// Values old
//const float fitA = -0.00008537;
//const float fitB = 5.107;
//const float fitC = -4590;


// Spin Coater Programs
// Limited to 10 at the beginning
const unsigned int maxProg = 10;
const unsigned int maxSteps = 10;
unsigned long spinSteps[maxProg][maxSteps][3];
unsigned int progNumber = 0;
String progName[maxProg];
const unsigned int maxRemote = 20;
unsigned long remoteProg[maxRemote][3];
int delayValue = 0;
unsigned long shortTime = 0;


// Menu counter
/**
 * 0    list menu
 * 1    main menu
 * 2    edit menu
 * 3    running menu
 */
byte menuCount = 0;
byte lastMenu = 0;
bool menuSwitch = true;
unsigned int displayListStart = 0;

bool killLoop = false;
bool shortLoop = false;


// ___________DO NOT EDIT till _______________
  String clLine = "";
  LiquidCrystal lcd(rs, en, d0, d1, d2, d3, d4, d5, d6, d7);
  Servo ESC;
  Servo shutter;
//_____________________________________________




// Setup Settings_______________________________________________________________

/**/
void serialSetting() {
  Serial.begin(115200);
  Serial.println("Serial Finshed");
}

/**/
void pinSetting() {
  pinMode(escStartPin, OUTPUT);
  Serial.println("pinSetting Finshed");
}

/**/
void buttonSetting() {
  pinMode(buttonUp, INPUT_PULLUP);
  pinMode(buttonDown, INPUT_PULLUP);
  pinMode(buttonLeft, INPUT_PULLUP);
  pinMode(buttonRight, INPUT_PULLUP);
  pinMode(buttonOK, INPUT_PULLUP);
  pinMode(buttonAbort, INPUT_PULLUP);
  Serial.println("buttonSetting Finshed");
}

/**/
void ledSetting() {
  pinMode(ledUp, OUTPUT);
  pinMode(ledDown, OUTPUT);
  pinMode(ledLeft, OUTPUT);
  pinMode(ledRight, OUTPUT);
  pinMode(ledOK, OUTPUT);
  pinMode(ledAbort, OUTPUT);
  digitalWrite(ledUp, HIGH);
  digitalWrite(ledDown, HIGH);
  digitalWrite(ledLeft, HIGH);
  digitalWrite(ledRight,HIGH);
  digitalWrite(ledOK, HIGH);
  digitalWrite(ledAbort, HIGH);
  Serial.println("ledSetting Finshed");
}

/**/
void lcdSetting() {
  defineClearLineString();
  lcd.begin(dispColumns, dispLines);
  lcd.setCursor(0,0);
  lcd.print("Start Up");
  lcd.setCursor(0,1);
  lcd.print("Please wait");
  Serial.println("LCDSetting Finshed");
}

/**/
void escSetting() {
  ESC.attach(escPin);
  ESC.writeMicroseconds(850);
  delay(200);
  digitalWrite(escStartPin, HIGH);
  /*ESC.writeMicroseconds(850);
  delay(200);
  ESC.writeMicroseconds(2000);
  delay(200);
  ESC.writeMicroseconds(1000);*/
  Serial.println("ESC Finshed");
}

/**/
void spectrometerSetting() {
  pinMode(trigger, OUTPUT);
  digitalWrite(trigger, LOW);
}

/**/
void shutterSetting() {
  shutter.attach(shutterPin);
  shutterClose();
  shutterStatus = false;
}

/**/
void startUp() { 
  Serial.println("Start StartUp");
  EEPROM.get(0, spinSteps);
  Serial.println("Reading Steps finished");
  //EEPROM.get(sizeof(spinSteps), progName);
}

/**/
void defineClearLineString() {
  for (int i = 0; i < dispColumns; i++) {
    clLine = clLine + " ";
  }
}

// End Setup Settings
// _____________________________________________________________________________


// Methods______________________________________________________________________

/**
 * clears line on the LCD display (writes spaces)
 * 
 * @param n   line, which should be cleared
 * 
 * @note sets cursor back to beginning of deleted line
 */
void clearLine(int n) {
  lcd.setCursor(0,n);
  lcd.print(clLine);
  lcd.setCursor(0,n);
}


/**
 * clears complete LCD display
 * 
 * @note sets cursor back to beginning of display
 */
void clearDisplay() {
  for (int i = 0; i < dispLines; i++) {
    lcd.setCursor(0,i);
    lcd.print(clLine);
  }
  lcd.setCursor(0,0);
}

/**
 * clears display at menu switch 
 */
void menuSwitchReset() {
  menuSwitch = false;
  clearDisplay();
}


/**
 * Moves shutter to specified position
 */
boolean shutterMoveTo(int position) {
  shutter.writeMicroseconds(position);
  return true;
}

/**
 * Opens shutter
 */
boolean shutterOpen() {
  return shutterMoveTo(shutterOn);
}

/**
 * Close shutter
 */
boolean shutterClose() {
  return shutterMoveTo(shutterOff);
}

boolean shutterToggle() {
  if (shutterStatus) {
    return shutterClose();
  } 
  return shutterOpen();
}

//_Menu_List____________________________________________________________________
/**
 * create menu list
 */
void createListMenu() {
  clearDisplay();
  for (int i=0; i < dispLines; i++) {
    lcd.setCursor(1,i);
    unsigned int tInt = (displayListStart + i)%maxProg;
    String temp = "Prg " + insertTrailing(String(tInt), "0", 2, true)
        + String(VLINE) + progName[tInt];
    lcd.print(temp);
  }
}

/**
 * Button Configuration for list menu
 */
void listMenuLoop() {
  createListMenu();
  lcd.setCursor(0,0);
  lcd.print(RARROW);
  currentLine = 0;
  currentTab = 0;

  while (!killLoop) {
    handleSerialInput();
    if (bDown.isPressed(false)) {
      progNumber++;
      progNumber = progNumber % maxProg;
      currentLine++;
      if (currentLine < dispLines) {
        lcd.setCursor(0,currentLine-1);
        lcd.print(" ");
        lcd.setCursor(0,currentLine);
        lcd.print(RARROW);
      } else {
        clearDisplay();
        displayListStart++;
        displayListStart = displayListStart % maxProg;
        createListMenu();
        lcd.setCursor(0,dispLines-1);
        currentLine--;
        lcd.print(RARROW);
      }
    }

    if (bUp.isPressed(false)) {
      progNumber--;
      progNumber = (progNumber + maxProg) % maxProg;
      if (currentLine != 0) {
        currentLine--;
        setMenuCursor(0,currentLine,0, currentLine+1);
      } else {
        displayListStart = (displayListStart - 1 + maxProg) % maxProg;
        createListMenu();
        lcd.setCursor(0,0);
        lcd.print(RARROW);
      }
    }

    if (bRight.isPressed(false)) {
      unsigned int temp = progNumber / 10;
      temp++;
      progNumber = temp*10;
      currentLine = 0;
      displayListStart = progNumber;
      createListMenu();
      lcd.setCursor(0,0);
      lcd.print(RARROW);
    }

    if (bLeft.isPressed(false)) {
      unsigned int temp = (progNumber+maxProg)/ 10;
      temp--;
      temp %= 10;
      progNumber = temp*10;
      currentLine = 0;
      displayListStart = progNumber;
      createListMenu();
      lcd.setCursor(0,0);
      lcd.print(RARROW);
    }

    if (bOK.isPressed(false)) {
      displayListStart = progNumber;
      menuCount = 1;  // jump to main menu
      return;
    }
  }
}

//_Menu_Main____________________________________________________________________

void prepareMainMenu(unsigned int col, unsigned int line) {
  clearDisplay();
  lcd.setCursor(1,0);
  String temp = "Prg " + insertTrailing(String(progNumber), " ", 2, true)
       + String(VLINE) + progName[progNumber];
  lcd.print(temp);
  lcd.setCursor(1,1);
  temp = "Start " + String(VLINE) + " Edit";
  lcd.print(temp);
  lcd.setCursor(1,2);
  temp = "Step 0";
  lcd.print(temp);
  updateDisplayStep(0);

  setMenuCursor(col, line, 0, 2);
}


void updateDisplayStep(unsigned int step) {
  clearLine(2);
  clearLine(3);
  lcd.setCursor(0,2);
  lcd.print(RARROW);
  lcd.setCursor(1,2);
  String temp = "Step " + String(step);
  lcd.print(temp);
  lcd.setCursor(1,3);
  temp = String(spinSteps[progNumber][step][0]) + " rpm " + VLINE + " " + 
      time2String(spinSteps[progNumber][step][1]/1000);
  lcd.print(temp);
}


void setMenuCursor(unsigned int newC, unsigned int newL, 
    unsigned int oldC, unsigned int oldL) {
  lcd.setCursor(oldC, oldL);
  lcd.print(" ");
  lcd.setCursor(newC, newL);
  lcd.print(RARROW);
}


void mainMenuLoop() {
  currentLine = 1;
  currentTab = 0;
  unsigned int tabPosition;
  unsigned int currentStep = 0;
  prepareMainMenu(0,1);

  while (!killLoop) {
    handleSerialInput();
    if (bDown.isPressed(false)) {
      unsigned int oldL = currentLine;
      unsigned int oldC = tabPosition;
      currentLine++;
      if (currentLine == dispLines-1) currentLine--;
      currentTab = 0;
      tabPosition = 0;
      setMenuCursor(tabPosition, currentLine, oldC, oldL);
    }
    if (bUp.isPressed(false)) {
      unsigned int oldL = currentLine;
      unsigned int oldC = tabPosition;
      if (currentLine != 0) currentLine--;
      currentTab = 0;
      tabPosition = 0;
      setMenuCursor(tabPosition, currentLine, oldC, oldL);
    }
    if (bRight.isPressed(false)) {
      switch (currentLine) {
        case 0:
          progNumber = (progNumber + 1) % maxProg;
          prepareMainMenu(0,0);
          break;
        case 1:
          if (currentTab == 0) {
            currentTab = 1;
            setMenuCursor(8,1,0,1);
          }
          break;
        case 2:
          currentStep = (currentStep + 1) % maxSteps; 
          updateDisplayStep(currentStep);
          break;
        default:
          break;
      }
    }
    if (bLeft.isPressed(false)) {
      switch (currentLine) {
        case 0:
          progNumber = (progNumber - 1 + maxProg) % maxProg;
          prepareMainMenu(0,0);
          break;
        case 1:
          if (currentTab == 1) {
            currentTab = 0;
            setMenuCursor(0,1,8,1);
          }
          break;
        case 2:
          currentStep = (currentStep + maxSteps - 1) % maxSteps; 
          updateDisplayStep(currentStep);
          break;
        default:
          break;
      }
    }
    if (bOK.isPressed(false)) {
      switch (currentLine) {
        case 1: 
          menuSwitch = true;
          switch (currentTab) {
            case 0:
              menuCount = 3;
              return;
            case 1:
              menuCount = 2;
              return;
          }
        default:
          break;
      }
    }
    if (bAbort.isPressed(false)) {
      menuCount = 0;
      menuSwitch = true;
      return;
    }
  }
}



//_Menu_Edit____________________________________________________________________
void prepareEditMenu() {
  clearDisplay();
  lcd.setCursor(1,0);
  String temp = "Prg " + insertTrailing(String(progNumber), " ", 2, true)
       + String(VLINE) + progName[progNumber];
  lcd.print(temp);

  lcd.setCursor(1,1);
  lcd.print("Step  0");

  temp = insertTrailing(String(spinSteps[progNumber][0][0]), "0", 4, true)
          + "rpm" + String(VLINE);
  temp = temp + " " + time2String(spinSteps[progNumber][0][1]/1000);
  lcd.setCursor(1,2);
  lcd.print(temp);

  lcd.setCursor(1,3);
  lcd.print("Finish " + String(VLINE) + " Abort");

  lcd.setCursor(0,0);
  lcd.print(RARROW);
}



void editMenuLoop() {
  currentLine = 0;
  currentTab = 0;
  unsigned int tabPosition = 0;
  unsigned int currentStep = 0;

  unsigned long spinStepsTemp[maxSteps][2];
    for (int i = 0; i < maxSteps; i++) {
      spinStepsTemp[i][0] = spinSteps[progNumber][i][0];
      spinStepsTemp[i][1] = spinSteps[progNumber][i][1];
    }
  String nameTemp = progName[progNumber];
  
  prepareEditMenu();

  bool buttonLoop = true;
  while (buttonLoop) {
    //handleSerialInput(); Deactivated to not interrupt changing settings
    if (bDown.isPressed(false)) {
      unsigned int oldL = currentLine;
      unsigned int oldC = tabPosition;
      currentLine ++;
      if (currentLine == dispLines) currentLine--;
      if (currentLine == 2) {
        if (currentTab == 0) {
          tabPosition = 0;
        }
        if (currentTab == 1) {
          tabPosition = 9;
        }
      }
      setMenuCursor(tabPosition, currentLine, oldC, oldL);
    }
    if (bUp.isPressed(false)) {
      unsigned int oldL = currentLine;
      unsigned int oldC = tabPosition;
      if (currentLine != 0) currentLine--;
      if (currentLine == 1) {
        tabPosition = 0;
      }
      setMenuCursor(tabPosition, currentLine, oldC, oldL);
    }
    if (bRight.isPressed(false)) {
      if (currentLine == 2 || currentLine == 3) {
        if (currentTab == 0) {
          currentTab = 1;
          unsigned int oldL = currentLine;
          unsigned int oldC = tabPosition;
          tabPosition = 9;
          setMenuCursor(tabPosition, currentLine, oldC, oldL);
        }
      }
      if (currentLine == 1) {
        currentStep = (currentStep + 1) % maxSteps;
        updateStepEditMenu(currentStep, spinStepsTemp);
      }
    }
    if (bLeft.isPressed(false)) {
      if (currentLine == 2 || currentLine == 3) {
        if (currentTab == 1) {
          currentTab = 0;
          unsigned int oldL = currentLine;
          unsigned int oldC = tabPosition;
          tabPosition = 0;
          setMenuCursor(tabPosition, currentLine, oldC, oldL);
        }
      }
      if (currentLine == 1) {
        currentStep = (currentStep - 1 + maxSteps) % maxSteps;
        updateStepEditMenu(currentStep, spinStepsTemp);
      }
    }
    if (bOK.isPressed(false)) {
      switch (currentLine) {
        case 0: {  //change program Name
          String temp = nameTemp;
          lcd.setCursor(8,0);
          lcd.cursor();
          unsigned int posOffset = 8;
          unsigned int pos = 0;
          unsigned int possibleLength = dispColumns-posOffset;
          String arrTemp[possibleLength];
          for (unsigned int i = 0; i < possibleLength; i++) {
            arrTemp[i] = temp.substring(i,i);
          }
          while (true) {
            if (bDown.isPressed(false)) {
              int charNumber = locateInCharList(arrTemp[pos]);
              charNumber = (charNumber - 1 + cListLen) % cListLen;
              arrTemp[pos] = charList[charNumber];
              lcd.print(charList[charNumber]);
              lcd.setCursor(pos + posOffset, 0);
            }
            if (bUp.isPressed(false)) {
              int charNumber = locateInCharList(arrTemp[pos]);
              charNumber = (charNumber + 1) % cListLen;
              arrTemp[pos] = charList[charNumber];
              lcd.print(charList[charNumber]);
              lcd.setCursor(pos + posOffset, 0);
            }
            if (bRight.isPressed(false)) {
              lcd.setCursor((pos+1) % possibleLength + posOffset,0);
              pos = (pos+1) % possibleLength;
            }
            if (bLeft.isPressed(false)) {
              lcd.setCursor((possibleLength+pos-1) % possibleLength + posOffset,0);
              pos = (possibleLength+pos-1) % possibleLength;
            }
            if (bOK.isPressed(false)) {
              lcd.noCursor();
              lcd.setCursor(0,0);
              temp = "";
              for (int i = 0; i < possibleLength; i++) {
                temp += arrTemp[i];
              }
              nameTemp = temp;
              break;
            }
            if (bAbort.isPressed(false)) {
              lcd.noCursor();
              lcd.setCursor(0,0);
              break;
            }
          }
          break;
        }
        case 2: {  // change speed or time
          if (currentTab == 0) { //change rpm
            unsigned int save = spinStepsTemp[currentStep][0];
            int maxDigit = 4;
            unsigned int spinTemp[maxDigit];

            for (int i = maxDigit-1; i >= 0; i--) {
              spinTemp[i] = save % 10;
              save /= 10;
            }

            save = spinStepsTemp[currentStep][0];
            lcd.setCursor(1,2);
            lcd.cursor();
            unsigned int pos = 0;
            unsigned int posOffset = 1;
            unsigned int possibleLength = 4;

            while (true) {
              if (bDown.isPressed(false)) {
                spinTemp[pos] = (spinTemp[pos] + 10 - 1) % 10;
                lcd.print(spinTemp[pos]);
                lcd.setCursor(pos+posOffset,2);
              }
              if (bUp.isPressed(false)) {
                spinTemp[pos] = (spinTemp[pos] + 1) % 10;
                lcd.print(spinTemp[pos]);
                lcd.setCursor(pos+posOffset,2);
              }
              if (bRight.isPressed(false)) {
                lcd.setCursor((pos+1) % possibleLength + posOffset,2);
                pos = (pos+1) % possibleLength;
              }
              if (bLeft.isPressed(false)) {
                lcd.setCursor((possibleLength+pos-1) % possibleLength + posOffset, 2);
                pos = (possibleLength+pos-1) % possibleLength;
              }
              if (bOK.isPressed(false)) {
                lcd.noCursor();
                lcd.setCursor(0,2);
                unsigned int factor = 1;
                spinStepsTemp[currentStep][0] = 0;
                for (int i = maxDigit - 1; i >= 0; i--) {
                  spinStepsTemp[currentStep][0] += spinTemp[i]*factor;
                  factor *= 10;
                }
                break;
              }
              if (bAbort.isPressed(false)) {
                lcd.setCursor(1,2);
                lcd.print(insertTrailing(
                  String(spinStepsTemp[currentStep][0]), "0", 4, true));
                lcd.noCursor();
                lcd.setCursor(0,2);
                break;
              }
            }
          }
          if (currentTab == 1) { // change Time
            unsigned int save = spinStepsTemp[currentStep][1]/1000;
            // calculate digits
            unsigned long spinTemp[4];
            spinTemp[0] = (save/60) / 10;
            spinTemp[1] = (save/60) % 10;
            spinTemp[2] = (save%60) / 10;
            spinTemp[3] = (save%60) % 10;

            lcd.setCursor(10,2);
            lcd.cursor();
            unsigned int pos = 0;
            unsigned int posOffset = 10;
            unsigned int possibleLength = 4;

            while (true) {
              if (bDown.isPressed(false)) {
                unsigned int digitLimit = 10;
                if (pos == 2) digitLimit = 6;
                spinTemp[pos] = (spinTemp[pos] + digitLimit - 1) % digitLimit;
                lcd.print(spinTemp[pos]);
                lcd.setCursor(pos+posOffset,2);
              }
              if (bUp.isPressed(false)) {
                unsigned int digitLimit = 10;
                if (pos == 2) digitLimit = 6;
                spinTemp[pos] = (spinTemp[pos] + 1) % digitLimit;
                lcd.print(spinTemp[pos]);
                lcd.setCursor(pos+posOffset,2);
              }
              if (bRight.isPressed(false)) {
                pos = (pos+1) % possibleLength;
                if (pos > 1) {posOffset = 11;}
                else {posOffset = 10;}
                lcd.setCursor(pos + posOffset, 2);
              }
              if (bLeft.isPressed(false)) {
                pos = (pos + possibleLength - 1) % possibleLength;
                if (pos > 1) {posOffset = 11;}
                else {posOffset = 10;}
                lcd.setCursor(pos + posOffset, 2);
              }
              if (bOK.isPressed(false)) {
                lcd.noCursor();
                lcd.setCursor(9,2);
                Serial.println(1000*((spinTemp[0]*10 + spinTemp[1])*60 + spinTemp[2]*10 + spinTemp[3]));
                spinStepsTemp[currentStep][1] = 
                  1000*((spinTemp[0]*10 + spinTemp[1])*60 + spinTemp[2]*10 + spinTemp[3]);
                Serial.println(spinStepsTemp[currentStep][1]);  
                  break;
              }
              if (bAbort.isPressed(false)) {
                lcd.setCursor(10,2);
                lcd.print(time2String(spinStepsTemp[currentStep][1]));
                lcd.noCursor();
                lcd.setCursor(9,2);
                break;
              }
            }
          }
          break;
        }
        case 3: {
          if (currentTab == 0) { // save all new settings
            progName[progNumber] = nameTemp;
            for (int i = 0; i < maxSteps; i++) {
              spinSteps[progNumber][i][0] = spinStepsTemp[i][0];
              spinSteps[progNumber][i][1] = spinStepsTemp[i][1];
            }
          }
          EEPROM.put(0, spinSteps);
          //EEPROM.put(sizeof(spinSteps), progName);
          menuCount = 1;
          menuSwitch = true;
          buttonLoop = false;
          break;
        }
        default: break;
      }
    }
    if (bAbort.isPressed(false)) {
      if (currentLine == 3 && currentTab == 1) { // abort menu without saving
          menuCount = 1;
          menuSwitch = true;
          buttonLoop = false;
          break;
      } else {
        unsigned int oldL = currentLine;
        unsigned int oldC = tabPosition;
        tabPosition = 9;
        currentLine = 3;
        currentTab = 1;
        setMenuCursor(tabPosition, currentLine, oldC, oldL);
      }
    }
  }
}

int locateInCharList(String str) {
  for (int i = 0; i < cListLen; i++) {
    if (str.equals(charList[i]))
      return i;
  }
  return -1;
}

void updateStepEditMenu(unsigned int step, unsigned long arr[][2]) {
  clearLine(2);
  lcd.setCursor(6,1);
  lcd.print(insertTrailing(String(step)," ", 2, true));
  lcd.setCursor(1,2);
  String temp = 
           insertTrailing(String(arr[step][0]), "0", 4, true)
           + "rpm" + VLINE + " ";
  temp += time2String(arr[step][1]/1000);
  lcd.print(temp);
}

/**
 * Adds a String multiple times till it has a specific length
 * if trim is false, the returned string is allowed to be longer than number
 * 
 * @param   str               String which should be expanded
 *          trailingString    String which will be added to str
 *          len               length of string after trailing added 
 *                            (minimum length if trim = false)
 *          trim              if string is trimed to len
 */
String insertTrailing(String str, String trailingString,
     unsigned int len, bool trim) {
  if (str.length() > len) return str;
  int countTrailing = (len-str.length())/trailingString.length() + 1;
  String temp = "";
  for (int i = 0; i < countTrailing; i++) {
    temp += trailingString;
  }
  temp += str;
  if (trim) {
    temp = temp.substring(temp.length()-len);
  }
  return temp;
}

/**
 * This method just prepares the array for the real Method
 * Done for easier integration of remote use
 */
void runMenu() {
  unsigned int countSteps = 0;
  unsigned long arr[maxSteps][3];
  for (int i = 0; i < maxSteps; i++) {
    arr[i][0] = spinSteps[progNumber][i][0];
    arr[i][1] = spinSteps[progNumber][i][1];
  }
  prepareSpinCoaterArray(arr, maxSteps, false, 0);
}


void prepareSpinCoaterArray(unsigned long arr[][3], unsigned int size, bool remote, byte spinType) {
  clearDisplay();
  unsigned int countSteps = 0;
  for (int i = 0; i < size; i++) {
    
    if (arr[i][1] != 0) {
      countSteps++;
      
    }
  }
  unsigned long spinStart[countSteps][3];
  unsigned int countStepsTemp = 0;
  for (int i = 0; i < size; i++) {
    if (arr[i][1] != 0) {
      spinStart[countStepsTemp][0] = arr[i][0];
      spinStart[countStepsTemp][1] = arr[i][1];
      spinStart[countStepsTemp][2] = arr[i][2];
      countStepsTemp++;
    }
  }
  if (spinType == 0)  runSpinCoater(spinStart, countSteps, remote);
  if (spinType == 1)  runSpinCoaterShort(spinStart, countSteps, remote);
}

void runSpinCoater(unsigned long arr[][3], unsigned int maxStepProgram, bool remote) {
  // setting up display
  int tempDelay = 0;
  if (!remote) {
    lcd.setCursor(1,0);
    String temp = "Prg " + String(progNumber) + VLINE + progName[progNumber];
    lcd.print(temp);
    tempDelay = 0;
  } else {
    clearLine(0);
    lcd.setCursor(1,0);
    lcd.print("Remote Mode");
    tempDelay = delayValue;
  }

  lcd.setCursor(1,1);
  unsigned int maxStepProgramTemp = maxStepProgram;
  unsigned int digitCount = 1;
  while (maxStepProgramTemp / 10 != 0) {
    digitCount++;
    maxStepProgramTemp /= 10;
  }
  String temp = "Step " + insertTrailing(String(1), " ", digitCount, true) 
      + "/" + String(maxStepProgram);
  lcd.print(temp);

  lcd.setCursor(1,2);
  unsigned long totalTime = 0;
  for (int i = 0; i < maxStepProgram; i++) {
    totalTime += arr[i][1];
  }
  temp = time2String(arr[0][1]/1000) + "  " + VLINE + " " + time2String(totalTime/1000);
  lcd.print(temp);

  lcd.setCursor(1,3);
  temp = String(arr[0][0]) + "rpm";
  lcd.print(temp);


  // start spin coating
  if (tempDelay > 0) {
    shutterOpen();
    digitalWrite(trigger, HIGH);
    delay(tempDelay);
  }

  unsigned int timePassed = 0;
  for (int i = 0; i < maxStepProgram; i++) {
    unsigned int tempSpeed;
    if (i == 0) {
      tempSpeed = 0;
    } else {
      tempSpeed = arr[i-1][0];
    }
    unsigned long timeStart = setSpeed(tempSpeed, arr[i][0], arr[i][2]);
    if (i != 0) {
      totalTime -= arr[i-1][1];
    }
    lcd.setCursor(1,1);
    temp = "Step " + insertTrailing(String(i+1), " ", digitCount, true) 
      + "/" + String(maxStepProgram);
    lcd.print(temp);
    lcd.setCursor(1,3);
    temp = String(arr[i][0]) + "rpm";
    lcd.print(temp);
    unsigned long time2Pass = ((unsigned long)arr[i][1]);
    while ((millis()-timeStart) < time2Pass) {
      handleSerialInput();
      if (tempDelay < 0) {
        long timePassedDelay = 0;
        for (int j = 0; j < i; j++) {
          timePassedDelay -= ((long)arr[j][1]);
        }
        timePassedDelay -= millis();
        if (timePassedDelay < tempDelay) {
          shutterOpen();
          digitalWrite(trigger, HIGH);
        }
      }
      timePassed = (millis()-timeStart)/1000;
      lcd.setCursor(1,2);
      temp = time2String(arr[i][1]/1000-timePassed) + "  " + VLINE 
          + " " + time2String(totalTime/1000-timePassed);
      lcd.print(temp);
      if (bAbort.isPressed(false) || killLoop) {
        Serial.println("Abort");
        killLoop = false;
        i = maxStepProgram;
        shutterClose();
        break;
      }
    }
  }
  speedMotor(0);
  menuCount = 1;
  menuSwitch = true;
  digitalWrite(trigger, LOW);

  if (remote) {
    killLoop = true;
  }
}

void runSpinCoaterShort(unsigned long arr[][3], unsigned int maxStepProgram, bool remote) {
  // setting up display
  shortLoop = false;
  int tempDelay = 0;
  if (!remote) {
    lcd.setCursor(1,0);
    String temp = "Prg " + String(progNumber) + VLINE + progName[progNumber];
    lcd.print(temp);
    tempDelay = 0;
  } else {
    clearLine(0);
    lcd.setCursor(1,0);
    lcd.print("Remote Mode Short");
    tempDelay = delayValue;
  }

  lcd.setCursor(1,1);
  unsigned int maxStepProgramTemp = maxStepProgram;
  unsigned int digitCount = 1;
  while (maxStepProgramTemp / 10 != 0) {
    digitCount++;
    maxStepProgramTemp /= 10;
  }
  String temp = "Step " + insertTrailing(String(1), " ", digitCount, true) 
      + "/" + String(maxStepProgram);
  lcd.print(temp);

  lcd.setCursor(1,2);
  unsigned long totalTime = 0;
  for (int i = 0; i < maxStepProgram; i++) {
    totalTime += arr[i][1];
  }
  temp = time2String(arr[0][1]/1000) + "  " + VLINE + " " + time2String(totalTime/1000);
  lcd.print(temp);

  lcd.setCursor(1,3);
  temp = String(arr[0][0]) + "rpm";
  lcd.print(temp);


  // start spin coating
  if (tempDelay > 0) {
    shutterOpen();
    digitalWrite(trigger, HIGH);
    delay(tempDelay);
  }

  unsigned int timePassed = 0;
  for (int i = 0; i < maxStepProgram; i++) {
    unsigned int tempSpeed;
    if (i == 0) {
      tempSpeed = 0;
    } else {
      tempSpeed = arr[i-1][0];
    }
    unsigned long timeStart = setSpeed(tempSpeed, arr[i][0], arr[i][2]);
    if (i != 0) {
      totalTime -= arr[i-1][1];
    }
    lcd.setCursor(1,1);
    temp = "Step " + insertTrailing(String(i+1), " ", digitCount, true) 
      + "/" + String(maxStepProgram);
    lcd.print(temp);
    lcd.setCursor(1,3);
    temp = String(arr[i][0]) + "rpm";
    lcd.print(temp);
    unsigned long time2Pass = ((unsigned long)arr[i][1]);
    while ((millis()-timeStart) < time2Pass) {
      handleSerialInput();
      if (shortLoop) {
          time2Pass = shortTime;
          timeStart = millis();
          shortLoop = false;
          while((millis()-timeStart) < time2Pass) {
          }
          break;
      }
      if (tempDelay < 0) {
        long timePassedDelay = 0;
        for (int j = 0; j < i; j++) {
          timePassedDelay -= ((long)arr[j][1]);
        }
        timePassedDelay -= millis();
        if (timePassedDelay < tempDelay) {
          shutterOpen();
          digitalWrite(trigger, HIGH);
        }
      }
      handleSerialInput();
      if (shortLoop) {
          time2Pass = shortTime;
          timeStart = millis();
          shortLoop = false;
          while((millis()-timeStart) < time2Pass) {
          }
          break;
      }
      timePassed = (millis()-timeStart)/1000;
      lcd.setCursor(1,2);
      temp = time2String(arr[i][1]/1000-timePassed) + "  " + VLINE 
          + " " + time2String(totalTime/1000-timePassed);
      lcd.print(temp);
      handleSerialInput();
      if (shortLoop) {
          time2Pass = shortTime;
          timeStart = millis();
          shortLoop = false;
          while((millis()-timeStart) < time2Pass) {
          }
          break;
      }
      if (bAbort.isPressed(false) || killLoop) {
        Serial.println("Abort");
        killLoop = false;
        i = maxStepProgram;
        shutterClose();
        break;
      }
    }
  }
  speedMotor(0);
  menuCount = 1;
  menuSwitch = true;
  digitalWrite(trigger, LOW);

  if (remote) {
    killLoop = true;
  }
}

String time2String(unsigned int value) {
  unsigned int min = value/60;
  unsigned int sec = value % 60;
  return insertTrailing(String(min), "0", 2, true) + ":" 
      + insertTrailing(String(sec), "0", 2, true);
}

unsigned long setSpeed(unsigned int speedOld, unsigned int speedNew, unsigned int acc) {
  unsigned long startTime = millis();
  if (acc != 0 && speedNew > speedOld) {
    unsigned int diffSpeed = speedNew - speedOld;
    unsigned long maxTime = (unsigned long)(diffSpeed/acc*1000);
    startTime = millis();
    while ((millis()-startTime) < maxTime) {
      speedMotor((millis()-startTime)*acc/1000 + speedOld);
    }
  }
  speedMotor(speedNew);
  return startTime;
}

void speedMotor(unsigned int rpm) {
  if (rpm == 0) {
    ESC.writeMicroseconds(850);
  } else {
    switch (calibMethod) {
      case 0: { // linear interpolation
        int temp = map(rpm, calib[0][1], calib[1][1], calib[0][0], calib[1][0]);
        ESC.writeMicroseconds(temp);
        break;
      }
      case 1: { //2nd order poly fit
        int temp = (-fitB + sqrt(fitB*fitB - 4*(fitC-rpm)*fitA)) / (2*fitA);
        temp = constrain(temp, 980, 2050);
        ESC.writeMicroseconds(temp);
        break;
      }
      default: break;
    }
    
  } 
}


//_Serial_Input_________________________________________________________________
void handleSerialInput() {
  if (Serial.available() > 0) {
    String in = Serial.readStringUntil(TERMINATOR);

    if (in.startsWith("abo")) { // abort
      if (menuCount == 3) killLoop = true;
      Serial.print("abo");
      return;
    }

    if (in.startsWith("sho")) {
        shortLoop = true;
        Serial.print("j");
        return;
    }

    if (in.startsWith("run")) { // start spin coater
      in = in.substring(3);
      if (in.startsWith("Normal")) {
          Serial.print("run normal");
          prepareSpinCoaterArray(remoteProg, sizeof(remoteProg)/sizeof(remoteProg[0]), true, 0);
      }
      if (in.startsWith("Short")) { // spin coater will run till it gets a from pc or time is over
          Serial.print("run short"); 
          prepareSpinCoaterArray(remoteProg, sizeof(remoteProg)/sizeof(remoteProg[0]), true, 1);
      }
    }

    if (in.startsWith("!")) {
      in = in.substring(1);
      if (in.startsWith("spe")) { //speed Motor
        in = in.substring(3);
        int temp = in.toInt();
        speedMotor(temp);
        Serial.print("spe");
      }
      if (in.startsWith("mil")) { // speed Motor with millisecond timing
        in = in.substring(3);
        int temp = in.toInt();
        if (temp < 1000) {
          ESC.writeMicroseconds(1000);
        } else {
          if (temp > 2000) {
            ESC.writeMicroseconds(2000);
          } else {
            ESC.writeMicroseconds(temp);
          }
        }
        Serial.print("mil");
      }
      if (in.startsWith("shu")) { // shutter stuff
        in = in.substring(3);
        if (in.startsWith("ON")) shutterOpen();
        if (in.startsWith("OFF")) shutterClose();
        if (in.startsWith("TOG")) shutterToggle();
        if (in.startsWith("_M")) {
          in = in.substring(2);
          shutterMoveTo(in.toInt());
          shutterStatus = true;
        }
        Serial.print("shu");
      }
      if (in.startsWith("rem")) { // load spin coater program
        in = in.substring(3);
        for (int i = 0; i < maxRemote; i++) {
          remoteProg[i][0] = 0;
          remoteProg[i][1] = 0;
          remoteProg[i][2] = 0;
        }
        // Get Terminator Symbols
        unsigned int countTerminator = 0;
        for (int i = 0; i < in.length(); i++) {
          if (in.charAt(i) == '_') countTerminator++;
        }
        // Get First Terminator for delay calculation
        int ind = in.indexOf("_");
        String temp = "";
        temp = in.substring(1,ind);
        if (in.charAt(0) == '+') {
            delayValue = temp.toInt();
        }
        if (in.charAt(0) == '-') {
            delayValue = - temp.toInt();
        }
        in = in.substring(ind+1);
        
        //Get Terminator for shortTime (in ms)
        ind = in.indexOf("_");
        shortTime = in.substring(0,ind).toInt(); //returns long
        in = in.substring(ind+1);


        for (int i = 0; i < countTerminator-1; i++) { //modified for shortTime
          int ind = in.indexOf("_");
          String temp = "";
          if (ind != -1) {
            temp = in.substring(0, ind);
            in = in.substring(ind+1);
          } else {
            temp = in;
          }
          remoteProg[i/3][i%3] = temp.toInt();
        }
        Serial.print("rem");
        //Serial.println("Finish");
      }
    }

    if (in.startsWith("reset")) {
      in = in.substring(5);
      if (in.startsWith("EEPROM")) {
        Serial.println("Really reset the EEPROM?");
        Serial.println("All Programs will be deleted. (y/n)");
        while (Serial.available() == 0) {};
        in = Serial.readStringUntil(TERMINATOR);
        Serial.println(in);
        if (in.startsWith("y")) { //reset EEPROM
          memset(spinSteps, 0, sizeof(spinSteps));
          EEPROM.put(0, spinSteps);
          Serial.println("Reseted EEPROM");
        } else {
          Serial.println("Reset aborted");
        }
      }
    }
  }
}

// Setup and Loop ______________________________________________________________
void setup() {
  serialSetting();
  pinSetting();
  buttonSetting();
  ledSetting();
  lcdSetting();
  escSetting();
  spectrometerSetting();
  shutterSetting();
  startUp();
}

void loop() {
  Serial.println("loop");
  if (lastMenu != menuCount) menuSwitchReset();
  killLoop = false;
  clearDisplay();
  switch (menuCount) {
    case 0:
      listMenuLoop(); 
      break;
    case 1:
      mainMenuLoop();
      break;
    case 2:
      editMenuLoop();
      break;
    case 3:
      runMenu();
      break;
    default:
      //errorLoop();
      break;
  }
}
//EOF
