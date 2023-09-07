package game.elements;

import graphics.GameEngine;
import utils.Point2D;

public class Sword extends GameElement implements Pickable {

	public Sword(Point2D p) {
		super(p);
		super.setLayer(1);
		super.setName("Sword");
	}

	@Override
	public void pick() {
		GameEngine.getInstance().updatePoints(1);
		GameEngine.getInstance().removeElement(this);
	}

}
