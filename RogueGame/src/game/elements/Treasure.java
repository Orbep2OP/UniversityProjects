package game.elements;

import graphics.GameEngine;
import utils.Point2D;

public class Treasure extends GameElement implements Pickable {

	public Treasure(Point2D p) {
		super(p);
		super.setLayer(1);
		super.setName("Treasure");
	}

	@Override
	public void pick() {
		GameEngine.getInstance().updatePoints(100);
		GameEngine.getInstance().removeElement(this);
		GameEngine.getInstance().gameWon();
	}

}
