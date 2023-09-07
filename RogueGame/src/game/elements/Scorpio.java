package game.elements;

import graphics.GameEngine;
import utils.Point2D;

public class Scorpio extends GameElement implements Movable {

	private int hitpoints;

	public Scorpio(Point2D p) {
		super(p);
		super.setLayer(1);
		super.setName("Scorpio");
		this.hitpoints = 2;
	}

	@Override
	public Point2D Move(Point2D p) {

		int distanciaX = p.getX() - this.getPosition().getX();
		int distanciaY = p.getY() - this.getPosition().getY();

		int x = 0;
		int y = 0;

		if( distanciaX == 0 && distanciaY == 0 ) {
			return super.getPosition();
		}

		if( distanciaX == 0 && distanciaY > 0) {
			x = super.getPosition().getX();
			y = (super.getPosition().getY() + 1);
			return new Point2D(x,y);
		}

		if( distanciaX == 0 && distanciaY < 0) {
			x = super.getPosition().getX();
			y = (super.getPosition().getY() - 1);
			return new Point2D(x,y);
		}

		if( distanciaY == 0 && distanciaX > 0) {
			x = (super.getPosition().getX() + 1);
			y = super.getPosition().getY();
			return new Point2D(x,y);
		}

		if( distanciaY == 0 && distanciaX < 0) {
			x = (super.getPosition().getX() - 1);
			y = super.getPosition().getY();
			return new Point2D(x,y);
		}

		int xAux = distanciaX - super.getPosition().getX();
		int yAux = distanciaY - super.getPosition().getY();

		if(Math.abs(xAux) <= Math.abs(yAux)) {
			if(distanciaX > 0) {
				x = (super.getPosition().getX() + 1);
				y = super.getPosition().getY();
				return new Point2D(x,y);
			}
			else {
				x = (super.getPosition().getX() - 1);
				y = super.getPosition().getY();
				return new Point2D(x,y);
			}
		}

		if(distanciaY > 0) {
			x = super.getPosition().getX();
			y = (super.getPosition().getY() + 1);
			return new Point2D(x,y);
		}

		x = super.getPosition().getX();
		y = (super.getPosition().getY() - 1);
		return new Point2D(x,y);
	}

	@Override
	public void attack(GameElement GE) {
		GameEngine.getInstance().updatePoints(-1);
		((Hero) GE).poisoned();
	}

	@Override
	public void attacked(GameElement GE) {
		if(((Hero) GE).hasItem("Sword")) {
			this.hitpoints = this.hitpoints - 2;
		}
		else {
			this.hitpoints = this.hitpoints - 1;
		}

		if(isDead()) {
			GameEngine.getInstance().updatePoints(2);
			GameEngine.getInstance().removeElement(this);
		}
	}

	@Override
	public boolean isDead() {
		return (hitpoints <= 0);
	}

}
