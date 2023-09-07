package game.elements;

import java.awt.event.KeyEvent;
import java.util.ArrayList;
import java.util.List;

import graphics.GameEngine;
import utils.Direction;
import utils.Point2D;

public class Hero extends GameElement {

	private int hitpoints;
	private List<GameElement> inventory = new ArrayList<GameElement>();
	private boolean isPoisoned;

	public Hero(Point2D p) {
		super(p);
		this.hitpoints = 10;
		super.setName("Hero");
		super.setLayer(1);
		isPoisoned = false;
	}	

	public void pick(GameElement GE) {

		if(inventory.size() >= 3 && GE.getName().equals("Treasure") == false) {
			System.out.println("Hero's inventory is full");
			return;
		}

		switch(GE.getName()) {

		case "Key":
			inventory.add(GE);
			((Key) GE).pick();
			GameEngine.getInstance().getSB().updateInventoryBar(GE);
			return;

		case "Armor":
			inventory.add(GE);
			((Armor) GE).pick();
			GameEngine.getInstance().getSB().updateInventoryBar(GE);
			return;

		case "Sword":
			inventory.add(GE);
			((Sword) GE).pick();
			GameEngine.getInstance().getSB().updateInventoryBar(GE);
			return;

		case "HealingPotion":
			inventory.add(GE);
			((HealingPotion) GE).pick();
			GameEngine.getInstance().getSB().updateInventoryBar(GE);
			return;

		case "Treasure":
			((Treasure) GE).pick();
			return;

		default:
			System.out.println("Hero can't pick a: " + GE.getName());
			return;
		}
	}

	public int health() {
		return this.hitpoints;
	}

	public void heal() {
		int aux = this.hitpoints;
		aux = 5 + aux;

		if(hasItem("HealingPotion")) {
			GameEngine.getInstance().updatePoints(3);
			isPoisoned = false;
			if(aux > 10) {
				this.hitpoints = 10;
				GameEngine.getInstance().getSB().updateHealthBar(this);
				int index = GameEngine.getInstance().getSB().getIndexOfItemInInventoryBar("HealingPotion");
				GameEngine.getInstance().getSB().removeFromStatusBar(index + 1);
				inventory.removeIf(GE -> GE.getName().equals("HealingPotion"));
				return;
			}
			this.hitpoints = aux;
			GameEngine.getInstance().getSB().updateHealthBar(this);

			int index = GameEngine.getInstance().getSB().getIndexOfItemInInventoryBar("HealingPotion");
			GameEngine.getInstance().getSB().removeFromStatusBar(index + 1);

			inventory.removeIf(GE -> GE.getName().equals("HealingPotion"));
			return;
		}
		System.out.println("Hero doens't have a healing potion");
	}

	public boolean hasItem(String s) {
		for(GameElement GE: inventory) {
			if(GE.getName().equals(s)) {
				return true;
			}
		}
		return false;
	}

	public List<GameElement> getInventory(){
		return inventory;
	}

	public void attack(GameElement GE) {
		switch(GE.getName()) {

		case "Thug":
			GameEngine.getInstance().updatePoints(3);
			((Thug) GE).attacked(this);
			return;

		case "Bat":
			GameEngine.getInstance().updatePoints(1);
			((Bat) GE).attacked(this);
			return;

		case "Skeleton":
			GameEngine.getInstance().updatePoints(2);
			((Skeleton) GE).attacked(this);
			return;

		case "Thief":
			GameEngine.getInstance().updatePoints(1);
			((Thief) GE).attacked(this);
			return;

		case "Scorpio":
			GameEngine.getInstance().updatePoints(1);
			((Scorpio) GE).attacked(this);
			return;

		default:
			throw new IllegalArgumentException(GE.getName() + " " + "is not an enemy");
		}
	}

	public void poisoned() {
		this.isPoisoned = true;
	}

	public void attacked(GameElement GE) {

		if(hasItem("Armor")) {
			if(Math.random() < 0.5) {

				switch(GE.getName()) {

				case "Thug":
					this.hitpoints = this.hitpoints - ((Thug) GE).getAttackPower();
					if(isDead() == false) {
						GameEngine.getInstance().getSB().updateHealthBar(this);
					}
					return;

				case "Bat":
					this.hitpoints = this.hitpoints -((Bat) GE).getAttackPower();
					if(isDead() == false) {
						GameEngine.getInstance().getSB().updateHealthBar(this);
					}
					return;

				case "Skeleton":
					this.hitpoints = this.hitpoints - 1;
					if(isDead() == false) {
						GameEngine.getInstance().getSB().updateHealthBar(this);
					}
					return;

				case "Thief":
					if(inventory.size() != 0) {
						((Thief) GE).steal();
					}
					return;

				case "Scorpio":
					this.isPoisoned = true;
					return;

				default:
					throw new IllegalArgumentException(GE.getName() + " " + "is not an enemy");
				}
			}
			return;
		}

		switch(GE.getName()) {

		case "Thug":
			this.hitpoints = this.hitpoints - ((Thug) GE).getAttackPower();
			if(isDead() == false) {
				GameEngine.getInstance().getSB().updateHealthBar(this);
			}
			return;

		case "Bat":
			this.hitpoints = this.hitpoints -((Bat) GE).getAttackPower();
			if(isDead() == false) {
				GameEngine.getInstance().getSB().updateHealthBar(this);
			}
			return;

		case "Skeleton":
			this.hitpoints = this.hitpoints - 1;
			if(isDead() == false) {
				GameEngine.getInstance().getSB().updateHealthBar(this);
			}
			return;

		case "Thief":
			if(inventory.size() != 0) {
				((Thief) GE).steal();
			}
			return;

		case "Scorpio":
			this.isPoisoned = true;
			return;

		default:
			throw new IllegalArgumentException(GE.getName() + " " + "is not an enemy");
		}

	}

	public boolean isDead() {
		if(this.hitpoints <= 0) {
			GameEngine.getInstance().reStart("Hero died :( do you still want to play?, if YES write YES, if NO write NO", false);
			return true;
		}
		return false;
	}

	public void openADoor(GameElement GE) {
		if(((Door) GE).isClosed()) {
			for(GameElement GE1: inventory) {
				if(GE1.getName().equals("Key")) {
					if(((Door) GE).keyForDoor().equals(((Key) GE1).getKeyId())) {
						((Door) GE).unlockDoor();
						return;
					}
				}
			}
		}
	}


	public void MoveHero(int key) {

		if(isPoisoned) {
			this.hitpoints = this.hitpoints - 1;
			if(isDead() == false) {
				GameEngine.getInstance().getSB().updateHealthBar(this);
			}
		}

		Direction d = Direction.directionFor(key);
		Point2D Newpos = super.getPosition().plus(d.asVector());
		GameElement GEp = viablePosition(Newpos, GameEngine.getInstance().getCurrentRoom());

		if(GEp.getLayer() == 0 ) {
			super.setPosition(Newpos); 
		}
		else {
			if(GEp instanceof Movable) {
				attack(GEp);
			}
			else {
				if(GEp instanceof Pickable) {
					super.setPosition(Newpos); 
					pick(GEp);
				}
				else {
					if(GEp.getName().equals("DoorClosed")) {
						openADoor(GEp);
					}
					else {
						if(GEp.getName().equals("DoorOpen")) {

							if(GameEngine.getInstance().oldRoom(((Door) GEp).nextRoom())) {
								spawn(((Door) GEp).getPNextRoom());
								GameEngine.getInstance().addOldRoom(((Door) GEp).nextRoom());
								GameEngine.getInstance().getCurrentRoom().keepDoorOpen(((Door) GEp).getPNextRoom());
							}
							else {
								String file = "RogueGame/rooms/";
								String file1 = file.concat(((Door) GEp).nextRoom());
								String filename = file1.concat(".txt");
								spawn(((Door) GEp).getPNextRoom());
								GameEngine.getInstance().createRoom(filename);
								GameEngine.getInstance().getCurrentRoom().keepDoorOpen(((Door) GEp).getPNextRoom());
							}
						}
					}

				}

			}
		}
	}


	private void spawn(Point2D p) { 
		int x = p.getX();
		int y = p.getY();

		if(x == 0) {
			x = x + 1;
			this.setPosition( new Point2D(x,y));
		}

		if(x == 9) {
			x = x - 1;
			this.setPosition( new Point2D(x,y));
		}

		if(y == 0) {
			y = y + 1;
			this.setPosition( new Point2D(x,y));
		}

		if(y == 9) {
			y = y - 1;
			this.setPosition( new Point2D(x,y));
		}
	}

	public void dropItem(int key) {	
		if(key == KeyEvent.VK_H) {
			heal();
			return;
		}

		if(key == KeyEvent.VK_1 && GameEngine.getInstance().getSB().isSlotFull(0) ) {
			GameElement GEaux = GameEngine.getInstance().getSB().getinventoryBar()[0];
			inventory.removeIf(GE1 -> GE1.getName().equals(GEaux.getName()));
			GameEngine.getInstance().getSB().removeFromStatusBar(1);
			dropItemNear(GEaux);
			return;
		}


		if(key == KeyEvent.VK_2 && GameEngine.getInstance().getSB().isSlotFull(1) ) {
			GameElement GEaux = GameEngine.getInstance().getSB().getinventoryBar()[1];
			inventory.removeIf(GE1 -> GE1.getName().equals(GEaux.getName()));
			GameEngine.getInstance().getSB().removeFromStatusBar(2);
			dropItemNear(GEaux);
			return;
		}


		if(key == KeyEvent.VK_3 && GameEngine.getInstance().getSB().isSlotFull(2) ) {
			GameElement GEaux = GameEngine.getInstance().getSB().getinventoryBar()[2];
			inventory.removeIf(GE1 -> GE1.getName().equals(GEaux.getName()));
			GameEngine.getInstance().getSB().removeFromStatusBar(3);
			dropItemNear(GEaux);
			return;
		}

	}

}
