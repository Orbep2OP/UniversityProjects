package game.elements;

import graphics.GameEngine;
import utils.Point2D;

public class StatusBar {

	private Color[] healthBar = new Color[5];
	private GameElement[] inventoryBar  = new GameElement[3];

	public StatusBar() {
		for(int i = 0; i < healthBar.length; i++) {
			healthBar[i] = new Color(new Point2D(i,10), "Green" );
			GameEngine.getInstance().addImage(new Color (new Point2D(i,10), "Green" ));
		}

		for(int i = 0; i < inventoryBar.length; i++) {
			inventoryBar[i] = null;
		}

		for(int i = 5; i < GameEngine.GRID_WIDTH ; i++) {
			GameEngine.getInstance().addImage(new Color(new Point2D(i,10), "Black"));
		}

	}

	public GameElement[] getinventoryBar() {
		return inventoryBar;
	}

	public GameElement[] gethealth() {
		return healthBar;
	}

	public void updateInventoryBar(GameElement GE) {

		if(isSlotFull(0) == false) {
			GE.setPosition(new Point2D(5,10));
			inventoryBar[0] = GE;
			GameEngine.getInstance().addImage(GE);
			return;
		}

		if(isSlotFull(1) == false) {
			GE.setPosition(new Point2D(7,10));
			inventoryBar[1] = GE;
			GameEngine.getInstance().addImage(GE);
			return;
		}

		if(isSlotFull(2) == false) {
			GE.setPosition(new Point2D(9,10));
			inventoryBar[2] = GE;
			GameEngine.getInstance().addImage(GE);
			return;
		}

		throw new IllegalArgumentException("Can't store a: " + GE.getName());

	}

	public void removeFromStatusBar(int key) {
		if(isSlotFull(key - 1)) {
			GameEngine.getInstance().removeImage(inventoryBar[key - 1]);
			Point2D p = inventoryBar[key - 1].getPosition();
			GameEngine.getInstance().addImage(new Color(p, "Black"));
			inventoryBar[key - 1] = null;
			return;
		}
		System.out.println("No item in that position in inventory");
	}

	public void updateHealthBar(Hero H) {
		int hp = H.health();
		int numberOfGreens = 0;

		if(hp < 0 || hp > 10) {
			throw new IllegalArgumentException("Hero's health is at an unexcpected value");
		}

		if(hp == 10) {
			for(int i = 0; i < healthBar.length; i++) {
				healthBar[i] =  new Color(new Point2D(i,10), "Green");
				GameEngine.getInstance().addImage(healthBar[i]);
			}
			return;
		}
		else {
			if( (hp % 2) == 0 ) {
				numberOfGreens = (hp / 2);
				for(int x = 0; x < numberOfGreens; x++) {
					healthBar[x] =  new Color(new Point2D(x,10), "Green");
					GameEngine.getInstance().addImage(healthBar[x]);
				}
				for(int x2 = numberOfGreens; x2 < healthBar.length; x2++) {
					healthBar[x2] =  new Color(new Point2D(x2,10), "Red");
					GameEngine.getInstance().addImage(healthBar[x2]);
				}
				return;
			}

			int aux = hp - 1;
			numberOfGreens = (aux / 2);

			for(int x = 0; x < numberOfGreens; x++) {
				healthBar[x] =  new Color(new Point2D(x,10), "Green");
				GameEngine.getInstance().addImage(healthBar[x]);
			}

			for(int x2 = numberOfGreens; x2 < healthBar.length; x2++) {
				healthBar[x2] =  new Color(new Point2D(x2,10), "Red");
				GameEngine.getInstance().addImage(healthBar[x2]);
			}
			healthBar[numberOfGreens] = new Color(new Point2D(numberOfGreens,10), "GreenRed");
			return;
		}
	}

	public boolean isSlotFull(int i) {
		if(inventoryBar[i] == null) {
			return false;
		}
		return true;
	}

	public int numberOfFreeSlot() {
		int count = 0;
		for(int i = 0; i<inventoryBar.length; i++) {
			if(isSlotFull(i) == false) {
				count++;
			}
		}
		return count;
	}

	public int getIndexOfItemInInventoryBar(String s) {

		if(inventoryBar[0] != null) {
			if(inventoryBar[0].getName().equals(s)) {
				return 0;
			}
		}
		if(inventoryBar[1] != null) {
			if(inventoryBar[1].getName().equals(s)) {
				return 1;
			}
		}

		return 2;
	}

}
