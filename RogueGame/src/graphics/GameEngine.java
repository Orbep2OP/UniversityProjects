package graphics;

import java.awt.event.KeyEvent;
import java.util.ArrayList;
import java.util.List;
import game.elements.GameElement;
import game.elements.Hero;
import game.elements.Room;
import game.elements.StatusBar;
import gui.ImageMatrixGUI;
import observer.Observed;
import observer.Observer;
import utils.Direction;
import utils.Point2D;


public class GameEngine implements Observer{

    public static final int GRID_HEIGHT = 11;
    public static final int GRID_WIDTH = 10;

    private static GameEngine INSTANCE = null;
    private ImageMatrixGUI gui = ImageMatrixGUI.getInstance();
    private List<Room> roomList = new ArrayList<Room>();
    private String currentRoom = "room0";
    private int points;
    private Hero hero = new Hero(new Point2D (1,1));
    private StatusBar SB;
    private int turns = 0;

    public static GameEngine getInstance() {
        if (INSTANCE == null)
            INSTANCE = new GameEngine();
        return INSTANCE;
    }

    private GameEngine() {
        gui.registerObserver(this);
        gui.setSize(GRID_WIDTH, GRID_HEIGHT);
        gui.go();
    }

    public int getPoints() {
        return points;
    }

    public ImageMatrixGUI getgui() {
        return gui;
    }

    public void start() {
        SB = new StatusBar();
        Room room = new Room("RogueGame/rooms/room0.txt");
        room.buildRoom();
        roomList.add(room);
        gui.addImages(room.getTileList());
        for(GameElement GE: room.getActiveElements()) {
            gui.addImage(GE);
        }
        currentRoom = room.getName();
        gui.addImage(hero);
        for(GameElement GE: SB.gethealth()) {
            gui.addImage(GE);
        }
        gui.setStatusMessage("ROGUE - Turns: " + turns + " - " + "Current Room: " + currentRoom + " - "  + "Points: " + points);
        gui.update();
    }

    public Hero getHero() {
        return hero;
    }

    private void player(boolean wonthegame) {
        BestPlayers.updateRankings(wonthegame);
    }

    public void gameWon() {
        reStart("You won the game :) if you want to play again, please write YES else write NO", true);
    }

    public void updatePoints(int i) {
        points = points + i;
    }

    public boolean oldRoom(String s) {
        for(Room r: roomList) {
            if(r.getName().equals(s)) {
                return true;
            }
        }
        return false;
    }

    public void reStart(String situation, boolean wonTheGame) {
        String s = gui.askUser(situation);
        boolean b = true;

        if(s != null) {
            while(b) {

                switch(s) {
                    case "NO":
                        gui.dispose();
                        player(wonTheGame);
                        b = false;
                        return;

                    case "YES":
                        gui.clearImages();
                        roomList.clear();
                        SB = new StatusBar();
                        gui.removeImage(hero);
                        hero = new Hero(new Point2D(1,1));
                        turns = 0;
                        points = 0;
                        start();
                        b = false;
                        return;


                    default:
                        s = gui.askUser("Wrong asnwer, please write YES if you want to play agairn or write NO if you don't want to play");
                }
            }
        }
        gui.dispose();
    }

    public Room getCurrentRoom() {
        for(int i = 0; i < roomList.size(); i++) {
            if(roomList.get(i).getName().equals(currentRoom)) {
                return roomList.get(i);
            }
        }
        throw new IllegalArgumentException("Room: " + currentRoom + " " + "does not exist in roomList");
    }

    public StatusBar getSB() {
        return SB;
    }

    public List<Room> getRoomList() {
        return roomList;
    }

    public void createRoom(String filename) {
        Room.createARoom(filename);
    }

    public void updateCurrentRoom(String s) {
        currentRoom = s;
    }

    public void addOldRoom(String s) {
        Room.addOldRoom(s);
    }

    public void addElement(GameElement GE) {
        getCurrentRoom().getActiveElements().add(GE);
        gui.addImage(GE);
    }

    public void removeElement(GameElement GE) {
        for(GameElement GE1: getCurrentRoom().getActiveElements()) {
            if(GE1.getPosition().equals(GE.getPosition())) {
                gui.removeImage(GE1);
            }
        }
        getCurrentRoom().getActiveElements().removeIf(GE2 -> GE2.getPosition().equals(GE.getPosition()));
    }

    public void addImage(GameElement GE) {
        gui.addImage(GE);
    }

    public void removeImage(GameElement GE) {
        gui.removeImage(GE);
    }

    public int turns() {
        return turns;
    }

    public void update(Observed source) {
        int key = ((ImageMatrixGUI) source).keyPressed();
        if(key == KeyEvent.VK_1 || key == KeyEvent.VK_2 || key == KeyEvent.VK_3 || key == KeyEvent.VK_H ) {
            hero.dropItem(key);
        }

        if(Direction.isDirection(key)) {
            turns++;
            hero.MoveHero(key);
            GameElement.Movables(hero);
        }
        gui.setStatusMessage("ROGUE - Turns: " + turns + " - " + "Current Room: " + currentRoom + " - "  + "Points: " + points);
        gui.update();
    }
}