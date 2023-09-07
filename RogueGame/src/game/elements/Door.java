package game.elements;

import graphics.GameEngine;
import utils.Point2D;

public class Door extends GameElement {

	private boolean locked;
	private String keyId;
	private String nextRoom;
	private Point2D pNextRoom;

	public Door(Point2D p, String nextRoom, Point2D p2, String keyId) {
		super(p);
		super.setLayer(1);
		super.setName("DoorClosed");
		this.keyId = keyId;
		this.nextRoom = nextRoom;
		this.pNextRoom = p2;
		this.locked = true;
	}

	public Door(Point2D p, String nextRoom, Point2D p2) {
		super(p);
		super.setLayer(1);
		super.setName("DoorOpen");
		this.nextRoom = nextRoom;
		this.pNextRoom = p2;
		this.locked = false;
	}

	public boolean isClosed() {
		return locked;
	}

	public String keyForDoor() {
		return keyId;
	}

	public String nextRoom() {
		return this.nextRoom;
	}

	public Point2D getPNextRoom() {
		return pNextRoom;
	}

	public void unlockDoor() {
		locked = false;
		GameEngine.getInstance().updatePoints(2);
		GameEngine.getInstance().removeElement(this);
		super.setName("DoorOpen");
		GameEngine.getInstance().addElement(this);
	}




}
