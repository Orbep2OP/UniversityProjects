package game.elements;

import graphics.GameEngine;
import utils.Point2D;

public class Thug extends GameElement implements Movable {

	private int hitpoints;

	public Thug(Point2D p) {
		super(p);
		super.setLayer(1);
		super.setName("Thug");
		this.hitpoints = 10;
	}

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
	public void attacked(GameElement GE) {
		if(((Hero) GE).hasItem("Sword")) {
			this.hitpoints = this.hitpoints - 2;
		}
		else {
			this.hitpoints = this.hitpoints - 1;
		}

		if(isDead()) {
			GameEngine.getInstance().updatePoints(10);
			GameEngine.getInstance().removeElement(this);
		}
	}

	@Override
	public void attack(GameElement GE) {
		GameEngine.getInstance().updatePoints(-4);
		((Hero) GE).attacked(this);
	}

	public int getAttackPower() {
		if(Math.random() < 0.28) {
			return 3;
		}
		return 0;
	}
	
	@Override
	public boolean isDead() {
		return (hitpoints <= 0);
	}





}
