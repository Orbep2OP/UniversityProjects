package game.elements;

import graphics.GameEngine;
import utils.Point2D;

public class Key extends GameElement implements Pickable {

	private String ID;

	public Key(Point2D p, String s) {
		super(p);
		super.setLayer(1);
		super.setName("Key");
		this.ID = s;
	}
	public Key(Key k) {
		super(k.getPosition());
		super.setLayer(k.getLayer());
		super.setName("Key");
		this.ID = k.getKeyId();
	}

	public String getKeyId() {
		return this.ID;
	}

	@Override
	public void pick() {
		GameEngine.getInstance().updatePoints(1);
		GameEngine.getInstance().removeElement(this);
	}

}
