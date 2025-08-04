#include "violet_ai.hpp"
#include <cmath>
#include <random>

VioletAI::VioletAI() :
		PastorAI() {
}

int VioletAI::calculateIndex(int square, int pieceType, int side) {
	return side * 64 * 6 + pieceType * 64 + square;
}

LinearLayer::LinearLayer(int in_f, int out_f) :
		in_features(in_f), out_features(out_f) {
	std::default_random_engine gen;
	std::normal_distribution<float> dist(0.0f, 0.01f);

	weight.resize(out_f, std::vector<float>(in_f));
	grad_weight.resize(out_f, std::vector<float>(in_f, 0.0f));
	bias.resize(out_f, 0.0f);
	grad_bias.resize(out_f, 0.0f);

	for (int i = 0; i < out_f; ++i)
		for (int j = 0; j < in_f; ++j)
			weight[i][j] = dist(gen);
}

std::vector<std::vector<float>> LinearLayer::forward(const std::vector<std::vector<float>> &input) {
	input_cache = input;
	int batch = input.size();
	std::vector<std::vector<float>> output(batch, std::vector<float>(out_features, 0.0f));

	for (int b = 0; b < batch; ++b)
		for (int i = 0; i < out_features; ++i) {
			float sum = bias[i];
			for (int j = 0; j < in_features; ++j)
				sum += input[b][j] * weight[i][j];
			output[b][i] = sum;
		}

	return output;
}

std::vector<std::vector<float>> LinearLayer::backward(const std::vector<std::vector<float>> &grad_output) {
	int batch = grad_output.size();

	for (int i = 0; i < out_features; ++i) {
		grad_bias[i] = 0.0f;
		for (int j = 0; j < in_features; ++j)
			grad_weight[i][j] = 0.0f;
	}

	for (int b = 0; b < batch; ++b)
		for (int i = 0; i < out_features; ++i) {
			grad_bias[i] += grad_output[b][i];
			for (int j = 0; j < in_features; ++j)
				grad_weight[i][j] += grad_output[b][i] * input_cache[b][j];
		}

	std::vector<std::vector<float>> grad_input(batch, std::vector<float>(in_features, 0.0f));
	for (int b = 0; b < batch; ++b)
		for (int j = 0; j < in_features; ++j)
			for (int i = 0; i < out_features; ++i)
				grad_input[b][j] += grad_output[b][i] * weight[i][j];

	return grad_input;
}

void LinearLayer::sgd_update(float lr) {
	for (int i = 0; i < out_features; ++i) {
		bias[i] -= lr * grad_bias[i];
		for (int j = 0; j < in_features; ++j)
			weight[i][j] -= lr * grad_weight[i][j];
	}
}

void NNUE::train(const std::vector<std::vector<int>> &x, const std::vector<float> &y, float lr, int epoch) {
}

std::vector<std::vector<float>> ReluLayer::forward(const std::vector<std::vector<float>> &input) {
	input_cache = input;
	std::vector<std::vector<float>> output = input;

	for (auto &row : output)
		for (auto &val : row)
			val = std::max(0.0f, val);

	return output;
}

std::vector<std::vector<float>> ReluLayer::backward(const std::vector<std::vector<float>> &grad_output) {
	std::vector<std::vector<float>> grad_input = grad_output;

	for (int i = 0; i < input_cache.size(); ++i)
		for (int j = 0; j < input_cache[0].size(); ++j)
			grad_input[i][j] *= (input_cache[i][j] > 0.0f) ? 1.0f : 0.0f;

	return grad_input;
}

float MSELoss::forward(const std::vector<std::vector<float>> &pred, const std::vector<std::vector<float>> &target) {
	y_pred = pred;
	y_true = target;
	float loss = 0.0f;
	int n = pred.size(), m = pred[0].size();

	for (int i = 0; i < n; ++i)
		for (int j = 0; j < m; ++j)
			loss += (pred[i][j] - target[i][j]) * (pred[i][j] - target[i][j]);

	return loss / (n * m);
}

std::vector<std::vector<float>> MSELoss::backward() {
	int n = y_pred.size(), m = y_pred[0].size();
	std::vector<std::vector<float>> grad(n, std::vector<float>(m));

	for (int i = 0; i < n; ++i)
		for (int j = 0; j < m; ++j)
			grad[i][j] = 2.0f * (y_pred[i][j] - y_true[i][j]) / (n * m);

	return grad;
}

std::vector<std::vector<float>> Concat::forward(const std::vector<std::vector<float>> &input1,
		const std::vector<std::vector<float>> &input2) {
	int batch_size = input1.size();
	int in_features1 = input1[0].size();
	int in_features2 = input2[0].size();

	// 拼接两个输入
	std::vector<std::vector<float>> output(batch_size, std::vector<float>(in_features1 + in_features2));

	for (int b = 0; b < batch_size; ++b) {
		for (int i = 0; i < in_features1; ++i)
			output[b][i] = input1[b][i];
		for (int i = 0; i < in_features2; ++i)
			output[b][in_features1 + i] = input2[b][i];
	}

	return output;
}

std::pair<std::vector<std::vector<float>>, std::vector<std::vector<float>>> Concat::backward(const std::vector<std::vector<float>> &grad_output, int input1_size, int input2_size) {
	int batch_size = grad_output.size();

	// 将 grad_output 切分为两个部分，分别对应 input1 和 input2
	std::vector<std::vector<float>> grad_input1(batch_size, std::vector<float>(input1_size, 0.0f));
	std::vector<std::vector<float>> grad_input2(batch_size, std::vector<float>(input2_size, 0.0f));

	// 将梯度拆分到对应的输入部分
	for (int b = 0; b < batch_size; ++b) {
		for (int i = 0; i < input1_size; ++i)
			grad_input1[b][i] = grad_output[b][i];

		for (int i = 0; i < input2_size; ++i)
			grad_input2[b][i] = grad_output[b][input1_size + i];
	}

	return { grad_input1, grad_input2 };
}

Accumulate::Accumulate() :
		LinearLayer(768, 8) {
}

std::vector<std::vector<float>> Accumulate::forward(const std::vector<std::vector<float>> &input) {
	input_cache = input;
	int batch = input.size();
	std::vector<std::vector<float>> output(batch, std::vector<float>(out_features, 0.0f));
	std::vector<std::vector<int>> active_features(batch, std::vector<int>());

	for (int b = 0; b < input.size(); b++) {
		for (int i = 0; i < input[i].size(); i++) {
			if ((bool)input[b][i]) {
				active_features[b].push_back(i);
			}
		}
	}

	for (int b = 0; b < batch; b++) {
		for (int i = 0; i < out_features; i++) {
			float sum = bias[i];
			for (int active : active_features[b]) {
				sum += weight[active][i];
			}
			output[b][i] = sum;
		}
	}

	return output;
}

std::vector<std::vector<float>> SigmoidLayer::forward(const std::vector<std::vector<float>> &input) {
	int batch = input.size();
	int dim = input[0].size();
	output_cache.resize(batch, std::vector<float>(dim));

	for (int i = 0; i < batch; ++i) {
		for (int j = 0; j < dim; ++j) {
			float val = 1.0f / (1.0f + std::exp(-input[i][j]));
			output_cache[i][j] = val;
		}
	}

	return output_cache;
}

std::vector<std::vector<float>> SigmoidLayer::backward(const std::vector<std::vector<float>> &grad_output) {
	int batch = grad_output.size();
	int dim = grad_output[0].size();
	std::vector<std::vector<float>> grad_input(batch, std::vector<float>(dim));

	for (int i = 0; i < batch; ++i) {
		for (int j = 0; j < dim; ++j) {
			float sig = output_cache[i][j];
			grad_input[i][j] = grad_output[i][j] * sig * (1.0f - sig);
		}
	}

	return grad_input;
}
