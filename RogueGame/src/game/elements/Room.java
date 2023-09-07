package game.elements;

import java.io.File;
import java.io.FileNotFoundException;
import java.util.ArrayList;
import java.util.List;
import java.util.Scanner;

import graphics.GameEngine;
import gui.ImageTile;
import utils.Point2D;

public class Room {

	private List<GameElement> activeElements = new ArrayList<GameElement>();
	private List<ImageTile> tileList = new ArrayList<ImageTile>();

	private String filename; 

	public Room(String filename) {
		this.filename = filename;
	}

	public String getName() {
		String[] s = filename.split("/");
		String[] s2 = s[2].split("[.]");
		return s2[0];
	}

	public List<GameElement> getActiveElements() {
		return activeElements;
	}

	public List<ImageTile> getTileList(){
		return tileList;
	}

	public void buildRoom() {

		int yaux = 0;
		for (int x=0; x!=GameEngine.GRID_WIDTH; x++) {
			for (int y=0; y!=GameEngine.GRID_HEIGHT - 1; y++) {
				tileList.add(new Floor(new Point2D(x,y)));
			}
		}

		try {
			Scanner scan = new Scanner(new File(filename));
			while(yaux < GameEngine.GRID_HEIGHT - 1) {
				char[] c = scan.nextLine().toCharArray();
				for(int i = 0; i < c.length; i++) {
					if(!Character.isWhitespace(c[i])) {
						this.tileList.add(new Wall(new Point2D(i,yaux)));
					}
				}
				yaux = yaux + 1;
			}

			scan.nextLine();
			while(scan.hasNextLine()) {
				String[] element = scan.nextLine().split(",");
				GameElement GE = GameElement.createAGameElement(element);
				this.activeElements.add(GE);
			}
			scan.close();
		}
		catch (FileNotFoundException e) {
			System.err.println("Ficheiro " + filename + " nao encontrado");
		}

	}

	public boolean notWall(Point2D p) {
		for(ImageTile w: tileList) {
			if(w.getName() == "Wall") {
				if(w.getPosition().equals(p)) { 
					return false;
				}
			}
		}
		return true;	
	}

	public List<GameElement> getEnemis(){
		List<GameElement> enemies = new ArrayList<GameElement>();
		for(GameElement GE: activeElements) {
			if(GE instanceof Movable) {
				enemies.add(GE);
			}
		}
		return enemies;
	}

	public static void createARoom(String filename) {
		GameEngine.getInstance().getgui().removeImages(GameEngine.getInstance().getCurrentRoom().getTileList());
		for(GameElement GE: GameEngine.getInstance().getCurrentRoom().getActiveElements()) {
			GameEngine.getInstance().getgui().removeImage(GE);
		}
		GameEngine.getInstance().getgui().removeImage(GameEngine.getInstance().getHero());
		Room room = new Room(filename);
		room.buildRoom();
		GameEngine.getInstance().getRoomList().add(room);
		GameEngine.getInstance().getgui().addImages(room.getTileList());

		for(GameElement GE: room.getActiveElements()) {
			GameEngine.getInstance().getgui().addImage(GE);
		}
		GameEngine.getInstance().updateCurrentRoom(room.getName());
		GameEngine.getInstance().getgui().addImage(GameEngine.getInstance().getHero());
	}

	public static void addOldRoom(String s) {
		GameEngine.getInstance().getgui().removeImages(GameEngine.getInstance().getCurrentRoom().getTileList());
		GameEngine.getInstance().getgui().removeImage(GameEngine.getInstance().getHero());
		for(GameElement GE: GameEngine.getInstance().getCurrentRoom().getActiveElements()) {
			GameEngine.getInstance().getgui().removeImage(GE);
		}

		for(Room r: GameEngine.getInstance().getRoomList()) {
			if(r.getName().equals(s)) {
				GameEngine.getInstance().updateCurrentRoom(r.getName());
				GameEngine.getInstance().getgui().addImages(r.getTileList());
				GameEngine.getInstance().getgui().addImage(GameEngine.getInstance().getHero());
				for(GameElement GE: r.getActiveElements()) {
					GameEngine.getInstance().getgui().addImage(GE);
				}
			}
		}
	}

	public void keepDoorOpen(Point2D p) {
		Door door = new Door(p, null, null);
		for(GameElement GE: GameEngine.getInstance().getCurrentRoom().getActiveElements()) {
			if(GE.getName().equals("DoorClosed") && GE.getPosition().equals(p)) {
				GameEngine.getInstance().removeImage(GE);
				door = (Door) GE;
			}
		}
		GameEngine.getInstance().getCurrentRoom().getActiveElements().removeIf(GE1 -> (GE1.getName().equals("DoorClosed") && GE1.getPosition().equals(p)));
		door.setName("DoorOpen");
		GameEngine.getInstance().getCurrentRoom().getActiveElements().add(door);
		GameEngine.getInstance().addImage(door);
	}





}
