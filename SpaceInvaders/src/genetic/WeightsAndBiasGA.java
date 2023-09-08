package genetic;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;

import nn.SimpleFeedforwardNeuralNetwork;
import space.Commons;
import space.SpaceInvaders;

public class WeightsAndBiasGA {
	
	private static final int POPULATION_SIZE = 100;
	private static final int NUM_GENERATIONS = 10;
	private static final double MUTATION_RATE = 0.35;
	
	public WeightsAndBiasGA(){
		// Initialize the population
		SimpleFeedforwardNeuralNetwork[] population = new SimpleFeedforwardNeuralNetwork[POPULATION_SIZE];
		for (int i = 0; i < POPULATION_SIZE; i++) {
			SimpleFeedforwardNeuralNetwork nn = new SimpleFeedforwardNeuralNetwork(Commons.STATE_SIZE, Commons.HIDDENLAYER, Commons.NUM_ACTIONS);
			nn.initializeWeights();
			nn.calculateFitness();
			population[i] = nn;
		}
		// Evolve the population for a fixed number of generations
		for (int i = 0; i < NUM_GENERATIONS; i++) {
			// Sort the population by fitness
			Arrays.sort(population);
			// Print the fitness of the best solution of this generation
			System.out.println("Generation " + i + ": \n" + population[0].getFitness());
			// Check if we have found an adequate solution
			if (population[0].getFitness() >= 890000.0) {
				break;
			}
			// Create the next generation
			SimpleFeedforwardNeuralNetwork[] newPopulation = new SimpleFeedforwardNeuralNetwork[POPULATION_SIZE];
			for (int j = 0; j <	POPULATION_SIZE; j++) {
				// Select two parents from the population
				SimpleFeedforwardNeuralNetwork parent1 = selectParent(population);
				SimpleFeedforwardNeuralNetwork parent2 = selectParent(population);
				// Crossover the parents to create a new child
				SimpleFeedforwardNeuralNetwork child = crossover(parent1, parent2);
				// Mutate the child
				mutate(child);
				child.calculateFitness();
				// Add the child to the new population
				newPopulation[j] = child;
			}
			// Replace the old population with the new population
			population = newPopulation;
		}
		// Print the best solution we found
		Arrays.sort(population);
		System.out.println("Best solution found: \n" + population[0].getFitness());
		SpaceInvaders.showControllerPlaying(population[0], Commons.SEED);
	}
	
	public static void main(String[] args) {
		new WeightsAndBiasGA();
	}
	
	// Select a parent from the population using tournament selection
	private SimpleFeedforwardNeuralNetwork selectParent(SimpleFeedforwardNeuralNetwork[] population) {
		ArrayList<SimpleFeedforwardNeuralNetwork> tournament = new ArrayList<>();
		for (int i = 0; i < 10; i++) {
			tournament.add(population[(int)(Math.random()*POPULATION_SIZE)]);
		}
		Collections.sort(tournament);
		return tournament.get(0);
	}
	
	// Crossover two parents to create a new child
	private SimpleFeedforwardNeuralNetwork crossover(SimpleFeedforwardNeuralNetwork parent1, SimpleFeedforwardNeuralNetwork parent2) {
		double[] child = new double[parent1.getChromossomeSize()];
		for (int i = 0; i < child.length; i++) {
			if (Math.random() < 0.5) {
				child[i] = parent1.getChromossome()[i];
			} else {
				child[i] = parent2.getChromossome()[i];
			}
		}
		return new SimpleFeedforwardNeuralNetwork(Commons.STATE_SIZE, Commons.HIDDENLAYER, Commons.NUM_ACTIONS, child);
	}
	
	// Mutate a neural network by randomly interchanging two of its nodes
	private void mutate(SimpleFeedforwardNeuralNetwork nn) {
		if (Math.random() < MUTATION_RATE) {
			double[] chromossome = nn.getChromossome();
			int i1 = (int)(Math.random()*nn.getChromossomeSize());
			int i2 = (int)(Math.random()*nn.getChromossomeSize());
			double x = chromossome[i1];
			double y = chromossome[i2];
			chromossome[i1] = y;
			chromossome[i2] = x;
			nn.setWeights(chromossome);
		}
	}
}