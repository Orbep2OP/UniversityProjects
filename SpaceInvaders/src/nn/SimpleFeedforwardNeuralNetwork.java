package nn;

import java.util.Random;

import controllers.GameController;
import space.Board;
import space.Commons;

public class SimpleFeedforwardNeuralNetwork implements GameController, Comparable<SimpleFeedforwardNeuralNetwork>{
	private int inputDim;
	private int hiddenDim;
	private int outputDim;
	private double[][] inputWeights;
	private double[] hiddenBiases;
	private double[][] outputWeights;
	private double[] outputBiases;
	
	private double fitness;

	public SimpleFeedforwardNeuralNetwork(int inputDim, int hiddenDim, int outputDim) {
		this.inputDim = inputDim;
		this.hiddenDim = hiddenDim;
		this.outputDim = outputDim;
		this.inputWeights = new double[inputDim][hiddenDim];
		this.hiddenBiases = new double[hiddenDim];
		this.outputWeights = new double[hiddenDim][outputDim];
		this.outputBiases = new double[outputDim];
		
		this.fitness = 0;
	}

	public SimpleFeedforwardNeuralNetwork(int inputDim, int hiddenDim, int outputDim, double[] values) {
		this(inputDim, hiddenDim, outputDim);
		int offset = 0;
		for (int i = 0; i < inputDim; i++) {
			for (int j = 0; j < hiddenDim; j++) {
				inputWeights[i][j] = values[i * hiddenDim + j];
			}
		}
		offset = inputDim * hiddenDim;
		for (int i = 0; i < hiddenDim; i++) {
			hiddenBiases[i] = values[offset + i];
		}
		offset += hiddenDim;
		for (int i = 0; i < hiddenDim; i++) {
			for (int j = 0; j < outputDim; j++) {
				outputWeights[i][j] = values[offset + i * outputDim + j];
			}
		}
		offset += hiddenDim * outputDim;
		for (int i = 0; i < outputDim; i++) {
			outputBiases[i] = values[offset + i];
		}
		
		this.fitness = 0;
	}

	public int getChromossomeSize() {
		return inputWeights.length * inputWeights[0].length + hiddenBiases.length
				+ outputWeights.length * outputWeights[0].length + outputBiases.length;
	}

	public double[] getChromossome() {
		double[] chromossome = new double[getChromossomeSize()];
		int offset = 0;
		for (int i = 0; i < inputDim; i++) {
			for (int j = 0; j < hiddenDim; j++) {
				chromossome[i * hiddenDim + j] = inputWeights[i][j];
			}
		}
		offset = inputDim * hiddenDim;
		for (int i = 0; i < hiddenDim; i++) {
			chromossome[offset + i] = hiddenBiases[i];
		}
		offset += hiddenDim;
		for (int i = 0; i < hiddenDim; i++) {
			for (int j = 0; j < outputDim; j++) {
				chromossome[offset + i * outputDim + j] = outputWeights[i][j];
			}
		}
		offset += hiddenDim * outputDim;
		for (int i = 0; i < outputDim; i++) {
			chromossome[offset + i] = outputBiases[i];
		}

		return chromossome;

	}

	public void initializeWeights() {
		// Randomly initialize weights and biases
		Random random = new Random();
		for (int i = 0; i < inputDim; i++) {
			for (int j = 0; j < hiddenDim; j++) {
				inputWeights[i][j] = random.nextDouble() - 0.5;
			}
		}
		for (int i = 0; i < hiddenDim; i++) {
			hiddenBiases[i] = random.nextDouble() - 0.5;
			for (int j = 0; j < outputDim; j++) {
				outputWeights[i][j] = random.nextDouble() - 0.5;
			}
		}
		for (int i = 0; i < outputDim; i++) {
			outputBiases[i] = random.nextDouble() - 0.5;
		}
	}
	
	public void setWeights(double[] values) {
		int offset = 0;
		for (int i = 0; i < inputDim; i++) {
			for (int j = 0; j < hiddenDim; j++) {
				inputWeights[i][j] = values[i * hiddenDim + j];
			}
		}
		offset = inputDim * hiddenDim;
		for (int i = 0; i < hiddenDim; i++) {
			hiddenBiases[i] = values[offset + i];
		}
		offset += hiddenDim;
		for (int i = 0; i < hiddenDim; i++) {
			for (int j = 0; j < outputDim; j++) {
				outputWeights[i][j] = values[offset + i * outputDim + j];
			}
		}
		offset += hiddenDim * outputDim;
		for (int i = 0; i < outputDim; i++) {
			outputBiases[i] = values[offset + i];
		}
	}

	public double[] forward(double[] d2) {
		// Compute output given input
		double[] hidden = new double[hiddenDim];
		for (int i = 0; i < hiddenDim; i++) {
			double sum = 0.0;
			for (int j = 0; j < inputDim; j++) {
				double d = d2[j];
				sum += d * inputWeights[j][i]; 
			}
			hidden[i] = Math.max(0.0, sum + hiddenBiases[i]);
		}
		double[] output = new double[outputDim];
		for (int i = 0; i < outputDim; i++) {
			double sum = 0.0;
			for (int j = 0; j < hiddenDim; j++) {
				sum += hidden[j] * outputWeights[j][i];
			}
			output[i] = Math.exp(sum + outputBiases[i]);
		}
		double sum = 0.0;
		for (int i = 0; i < outputDim; i++) {
			sum += output[i];
		}
		for (int i = 0; i < outputDim; i++) {
			output[i] /= sum;
		}
		return output;
	}

	@Override
	public double[] nextMove(double[] currentState) {
		return forward(currentState);
	}

	public double getFitness() {
		return fitness;
	}
	
	public void calculateFitness() {
		Board b = new Board(this);
		b.setSeed(Commons.SEED);
		b.run();
		this.fitness = b.getFitness();
	}
	
	@Override
	public int compareTo(SimpleFeedforwardNeuralNetwork nn) {
		return (int)(nn.getFitness() - this.getFitness());
	}
		

}